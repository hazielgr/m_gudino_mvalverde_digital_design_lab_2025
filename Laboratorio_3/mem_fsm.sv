module mem_fsm #(
    parameter int N_CARDS = 16,
    parameter int IDX_W   = $clog2(N_CARDS)
) (
    input  logic                 clk,
    input  logic                 rst_n,

    // Manual selection
    input  logic                 pick_valid,
    input  logic [IDX_W-1:0]     pick_idx,

    // From board
    input  logic                 idx_is_valid,
    input  logic                 match_equal,
    input  logic                 all_paired,

    // Auto-pick source
    input  logic                 auto_valid,
    input  logic [IDX_W-1:0]     auto_idx,

    // 15s timer
    input  logic                 timer15_done,
    output logic                 timer15_start,
    output logic                 timer15_reload,
    output logic                 timer15_stop,

    // Mini timer (mismatch hold/cover)
    input  logic                 mini_done,
    output logic                 mini_start,

    // Board/view
    output logic                 reveal_pulse,
    output logic [IDX_W-1:0]     idx_reveal,
    output logic                 pair_mark_pulse,

    // Control/score
    output logic [1:0]           cur_player,      // 0=J1, 1=J2
    output logic                 score_inc_pulse,
    output logic                 gameover,
    output logic [1:0]           winner,          // 0=J1, 1=J2, 2=Tie

    // Debug
    output logic [3:0]           fsm_state
);

    typedef enum logic [3:0] {
        S_INIT       = 4'd0,
        S_TURN_START = 4'd1,
        S_NAV1       = 4'd2,
        S_REV1       = 4'd3,
        S_NAV2       = 4'd4,
        S_REV2       = 4'd5,
        S_EVAL       = 4'd6,
        S_SHOWMISS   = 4'd7,
        S_AUTO1      = 4'd8,
        S_AUTO2      = 4'd9,
        S_GAMEOVER   = 4'd10
    } state_t;

    state_t state, nstate;
    assign fsm_state = state;

    // Internal selection latches
    logic [IDX_W-1:0] sel1_idx, sel2_idx;
    logic              sel1_valid, sel2_valid;

    // Simple internal score
    int score_j1, score_j2;

    // Current player (0: J1, 1: J2)
    logic cur_plr;
    assign cur_player = {1'b0, cur_plr};

    // Winner latched at GAMEOVER
    logic [1:0] winner_q;
    assign winner = winner_q;

    // Defaults
    always_comb begin
        nstate           = state;

        reveal_pulse     = 1'b0;
        idx_reveal       = '0;
        pair_mark_pulse  = 1'b0;
        score_inc_pulse  = 1'b0;

        timer15_start    = 1'b0;
        timer15_reload   = 1'b0;
        timer15_stop     = 1'b0;

        mini_start       = 1'b0;

        gameover         = 1'b0;

        unique case (state)
            S_INIT: begin
                timer15_stop  = 1'b1;
                nstate        = S_TURN_START;
            end

            S_TURN_START: begin
                // Clear selections and (re)start the 15s window
                timer15_reload = 1'b1;
                timer15_start  = 1'b1;
                nstate         = S_NAV1;
            end

            S_NAV1: begin
                // Wait for first pick or timeout -> AUTO1
                if (timer15_done) begin
                    nstate = S_AUTO1;
                end else if (pick_valid && idx_is_valid) begin
                    nstate = S_REV1;
                end
            end

            S_REV1: begin
                // Reveal first card
                reveal_pulse = 1'b1;
                idx_reveal   = pick_valid && idx_is_valid ? pick_idx : sel1_idx;
                nstate       = S_NAV2;
            end

            S_NAV2: begin
                // Wait for second pick (different index) or timeout -> AUTO2
                if (timer15_done) begin
                    nstate = S_AUTO2;
                end else if (pick_valid && idx_is_valid && (pick_idx != sel1_idx)) begin
                    nstate = S_REV2;
                end
            end

            S_REV2: begin
                // Reveal second card
                reveal_pulse = 1'b1;
                idx_reveal   = pick_valid && idx_is_valid ? pick_idx : sel2_idx;
                nstate       = S_EVAL;
            end

            S_EVAL: begin
                if (match_equal) begin
                    pair_mark_pulse = 1'b1;   // board will mark (top may delay actual write for a brief hold)
                    score_inc_pulse = 1'b1;
                    if (all_paired) begin
                        timer15_stop = 1'b1;
                        nstate       = S_GAMEOVER;
                    end else begin
                        // Keep the same player; refresh the 15s window for next pair
                        timer15_reload = 1'b1;
                        nstate         = S_TURN_START;
                    end
                end else begin
                    // Start short mismatch timer; on done we’ll flip player in the sequential block
                    mini_start = 1'b1;
                    nstate     = S_SHOWMISS;
                end
            end

            S_SHOWMISS: begin
                if (mini_done) begin
                    // New turn for the other player, with fresh 15s window in S_TURN_START
                    timer15_reload = 1'b1;
                    nstate         = S_TURN_START;
                end
            end

            S_AUTO1: begin
                // === CHANGE: when timer expires on first pick, auto-pick ONE card and
                // restart the 15s timer so the player gets a new window for the second pick ===
                if (auto_valid) begin
                    reveal_pulse   = 1'b1;
                    idx_reveal     = auto_idx;
                    timer15_reload = 1'b1;    // give a fresh 15s for second card
                    timer15_start  = 1'b1;
                    nstate         = S_NAV2;  // now wait for player; if they still time out, AUTO2 will fire
                end
            end

            S_AUTO2: begin
                // If second pick times out, auto-pick the second card now
                if (auto_valid) begin
                    reveal_pulse = 1'b1;
                    idx_reveal   = auto_idx;
                    nstate       = S_EVAL;
                end
            end

            S_GAMEOVER: begin
                gameover = 1'b1;
                nstate   = S_GAMEOVER;
            end

            default: nstate = S_INIT;
        endcase
    end

    // State/regs
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_INIT;
            sel1_idx   <= '0;
            sel2_idx   <= '0;
            sel1_valid <= 1'b0;
            sel2_valid <= 1'b0;
            cur_plr    <= 1'b0; // J1
            score_j1   <= 0;
            score_j2   <= 0;
            winner_q   <= 2'd0;
        end else begin
            state <= nstate;

            // Capture selected indices
            if (state == S_NAV1 && pick_valid && idx_is_valid) begin
                sel1_idx   <= pick_idx;
                sel1_valid <= 1'b1;
            end else if (state == S_AUTO1 && auto_valid) begin
                sel1_idx   <= auto_idx;
                sel1_valid <= 1'b1;
            end

            if (state == S_NAV2 && pick_valid && idx_is_valid && (pick_idx != sel1_idx)) begin
                sel2_idx   <= pick_idx;
                sel2_valid <= 1'b1;
            end else if (state == S_AUTO2 && auto_valid) begin
                sel2_idx   <= auto_idx;
                sel2_valid <= 1'b1;
            end

            // Clear selections at turn start
            if (state == S_TURN_START) begin
                sel1_valid <= 1'b0;
                sel2_valid <= 1'b0;
            end

            // Score on match
            if (state == S_EVAL && match_equal) begin
                if (cur_plr == 1'b0) score_j1 <= score_j1 + 1;
                else                  score_j2 <= score_j2 + 1;
            end

            // Switch player only on mismatch (after mini timer)
            if (state == S_SHOWMISS && mini_done) begin
                cur_plr <= ~cur_plr;
            end

            // Latch winner at gameover entry
            if (nstate == S_GAMEOVER) begin
                if (score_j1 > score_j2)      winner_q <= 2'd0; // J1
                else if (score_j2 > score_j1) winner_q <= 2'd1; // J2
                else                           winner_q <= 2'd2; // Tie
            end
        end
    end

endmodule
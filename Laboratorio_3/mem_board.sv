// ============================================================
// mem_board.sv  (Quartus-friendly)
// - 16-card memory board with reshuffle support
// - No block-scoped declarations inside always_ff
// - No (expr)[..] slicing; only simple bit selects
// ============================================================
module mem_board #(
    parameter int N_CARDS = 16,
    parameter int IDX_W   = 4,   // 0..15
    parameter int SYM_W   = 4    // store 0..7 (use 4 for simplicity)
) (
    input  logic                 clk,
    input  logic                 rst_n,

    // Query path (for "can I pick this?" checks)
    input  logic [IDX_W-1:0]     query_idx,
    output logic                 idx_is_valid,   // 1 = not matched, not revealed

    // Actions from FSM
    input  logic                 reveal_pulse,   // 1-cycle "flip this card up"
    input  logic [IDX_W-1:0]     idx_reveal,     // which card to reveal
    input  logic                 pair_mark_pulse,// 1-cycle "close pair" (and lock if equal)

    // Reshuffle control
    input  logic                 shuffle_pulse,  // 1-cycle: build new layout + clear board
    input  logic [15:0]          shuffle_seed,   // randomness source

    // Board state to FSM / renderer
    output logic [N_CARDS-1:0]   matched_mask,   // 1 = permanently matched
    output logic [N_CARDS-1:0]   revealed_mask,  // 1 = currently face-up (temp)
    output logic [IDX_W-1:0]     last_rev1,      // index of first revealed (if any)
    output logic                 have_rev1,      // 1 if first revealed exists

    // Per-card symbols (two of each 0..7 → 16 total). Constant between shuffles.
    output logic [SYM_W-1:0]     symbol_id [N_CARDS],

    // Pair/evaluation helpers
    output logic                 match_equal,    // 1 after second reveal & until pair_mark_pulse
    output logic                 all_paired      // 1 when all 16 are matched
);

    // ------------------------------------------------------------
    // Internals (module-scope only — no block-local decls)
    // ------------------------------------------------------------
    logic                 have_rev2;
    logic [IDX_W-1:0]     last_rev2;
    logic                 match_equal_q;

    // Loop indices (module-scope)
    integer j;
    integer idx;

    // Helpers for mapping (module-scope temps reused in loops)
    logic [1:0] r, c, rp, cp;

    // Affine permutation parameters derived from seed (combinational wires)
    // We use invertible maps on 2-bit domain:  rp = a_r * r + b_r (mod 4), a_r ∈ {1,3}
    // and similarly for columns. Yields 64 layouts; small but good variety.
    wire [1:0] b_row_w     = shuffle_seed[1:0];
    wire       a_row_sel_w = shuffle_seed[2];      // 0→a=1, 1→a=3
    wire [1:0] b_col_w     = shuffle_seed[5:4];
    wire       a_col_sel_w = shuffle_seed[6];      // 0→a=1, 1→a=3

    // 3*r (mod 4) == (-r) (mod 4) == (~r + 1) & 3 for 2-bit r
    function automatic logic [1:0] mul3mod4(input logic [1:0] v);
        mul3mod4 = ( ~v + 2'b01 ) & 2'b11;
    endfunction

    // ------------------------------------------------------------
    // State & layout
    // ------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matched_mask   <= '0;
            revealed_mask  <= '0;
            have_rev1      <= 1'b0;
            have_rev2      <= 1'b0;
            last_rev1      <= '0;
            last_rev2      <= '0;
            match_equal_q  <= 1'b0;

            // Default deterministic layout at power-up:
            // rows 0&2 → 0..3 ; rows 1&3 → 4..7
            for (j = 0; j < N_CARDS; j = j + 1) begin
                if ( ((j>>2) == 2) || ((j>>2) == 0) )
                    symbol_id[j] <= {2'b00, j[1:0]}; // 0..3
                else
                    symbol_id[j] <= {2'b01, j[1:0]}; // 4..7
            end
        end else begin
            // -------- Start a NEW GAME (reshuffle symbols, clear board) --------
            if (shuffle_pulse) begin
                // Clear board state
                matched_mask   <= '0;
                revealed_mask  <= '0;
                have_rev1      <= 1'b0;
                have_rev2      <= 1'b0;
                last_rev1      <= '0;
                last_rev2      <= '0;
                match_equal_q  <= 1'b0;

                // Build new layout with affine permutations on row/col
                for (idx = 0; idx < N_CARDS; idx = idx + 1) begin
                    r = idx[3:2];
                    c = idx[1:0];

                    // row map: rp = (a_r * r + b_row) mod 4 ; a_r ∈ {1,3}
                    rp = a_row_sel_w ? mul3mod4(r) : r;
                    rp = (rp + b_row_w) & 2'b11;

                    // col map: cp = (a_c * c + b_col) mod 4 ; a_c ∈ {1,3}
                    cp = a_col_sel_w ? mul3mod4(c) : c;
                    cp = (cp + b_col_w) & 2'b11;

                    // Fill symbol: rows {0,2} → 0..3 ; rows {1,3} → 4..7
                    if ((rp == 2'd0) || (rp == 2'd2))
                        symbol_id[idx] <= {2'b00, cp};
                    else
                        symbol_id[idx] <= {2'b01, cp};
                end
            end

            // -------- Handle a reveal request --------
            if (reveal_pulse) begin
                // Only act if the target is selectable (not matched, not already revealed)
                if (!matched_mask[idx_reveal] && !revealed_mask[idx_reveal]) begin
                    revealed_mask[idx_reveal] <= 1'b1;

                    if (!have_rev1) begin
                        // First card of the pair
                        have_rev1     <= 1'b1;
                        last_rev1     <= idx_reveal;
                        have_rev2     <= 1'b0;
                        last_rev2     <= '0;
                        match_equal_q <= 1'b0;
                    end else if (!have_rev2) begin
                        // Second card of the pair
                        have_rev2     <= 1'b1;
                        last_rev2     <= idx_reveal;
                        // Latch comparison result and hold until pair_mark_pulse
                        match_equal_q <= (symbol_id[last_rev1] == symbol_id[idx_reveal]);
                    end
                    // Further reveals ignored until pair_mark_pulse
                end
            end

            // -------- Close pair (and lock if equal) --------
            if (pair_mark_pulse) begin
                if (have_rev1 && have_rev2) begin
                    if (match_equal_q) begin
                        matched_mask[last_rev1] <= 1'b1;
                        matched_mask[last_rev2] <= 1'b1;
                    end
                    // Always hide the two revealed (equal or not)
                    revealed_mask[last_rev1] <= 1'b0;
                    revealed_mask[last_rev2] <= 1'b0;
                end
                // Clear pair tracking & comparison
                have_rev1     <= 1'b0;
                have_rev2     <= 1'b0;
                match_equal_q <= 1'b0;
            end
        end
    end

    // ------------------------------------------------------------
    // Combinational helpers / status
    // ------------------------------------------------------------
    // Is a query index selectable right now?
    always_comb begin
        idx_is_valid = 1'b0;
        if (!matched_mask[query_idx] && !revealed_mask[query_idx]) begin
            idx_is_valid = 1'b1;
        end
    end

    // All paired when all bits set
    assign all_paired = (matched_mask == {N_CARDS{1'b1}});

    // Expose comparison result held after the 2nd reveal
    assign match_equal = match_equal_q;

endmodule

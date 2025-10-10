`default_nettype none

module top_memory_game #(
    parameter bit ACTIVE_LOW_7SEG   = 1'b1, // 1 = segments active-low (0=ON)
    parameter bit REVERSE_SEG_ORDER = 1'b1  // 1 = output as g..a instead of a..g
)(
    input  logic        clk_50mhz,
    input  logic        rst_n,          // active-low

    // Buttons (shared)
    input  logic        btn_row,
    input  logic        btn_col,
    input  logic        btn_sel,

    // VGA
    output logic        vga_hsync,
    output logic        vga_vsync,
    output logic [7:0]  vga_r,
    output logic [7:0]  vga_g,
    output logic [7:0]  vga_b,
    output logic        vga_blank_n,
    output logic        vga_sync_n,
    output logic        vga_clk,

    // FSM state LEDs (optional)
    output logic [3:0]  fsm_state_leds,

    // Player turn LEDs
    output logic        led_player1,
    output logic        led_player2,

    // Six independent 7-seg (HEX5..HEX0), segments a..g in [6:0]
    output logic [6:0]  HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);
    // ---------------- VGA timing scaffolding ----------------
    assign vga_blank_n = 1'b1;
    assign vga_sync_n  = 1'b0;
    assign vga_clk     = clk_50mhz;

    logic pix_ce;
    pix_enable_div2 u_pixce (.clk_50(clk_50mhz), .rst_n(rst_n), .pix_ce(pix_ce));

    logic        video_on;
    logic [9:0]  x, y;
    vga_timing_640x480_en u_tim (
        .clk     (clk_50mhz),
        .rst_n   (rst_n),
        .pix_ce  (pix_ce),
        .hsync   (vga_hsync),   // active-low
        .vsync   (vga_vsync),   // active-low
        .video_on(video_on),
        .x       (x), .y(y)
    );

    // ---------------- Utility ticks ----------------
    // 1 kHz debounce
    logic [15:0] div1k; logic tick_1khz;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin div1k<=16'd0; tick_1khz<=1'b0; end
        else if (div1k==16'd49999) begin div1k<=16'd0; tick_1khz<=1'b1; end
        else begin div1k<=div1k+16'd1; tick_1khz<=1'b0; end
    end
    // 100 Hz (mini & match-hold)
    logic [19:0] div100; logic tick_100hz;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin div100<=20'd0; tick_100hz<=1'b0; end
        else if (div100==20'd499_999) begin div100<=20'd0; tick_100hz<=1'b1; end
        else begin div100<=div100+20'd1; tick_100hz<=1'b0; end
    end
    // 1 Hz (15 s)
    logic [25:0] div1; logic tick_1hz;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin div1<=26'd0; tick_1hz<=1'b0; end
        else if (div1==26'd49_999_999) begin div1<=26'd0; tick_1hz<=1'b1; end
        else begin div1<=div1+26'd1; tick_1hz<=1'b0; end
    end

    // ---------------- Debounced buttons ----------------
    logic row_pulse, col_pulse, sel_pulse;
    debounce_1shot u_db_row (.clk(clk_50mhz), .rst_n(rst_n), .tick_1khz(tick_1khz),
                             .btn_in(btn_row), .pulse(row_pulse));
    debounce_1shot u_db_col (.clk(clk_50mhz), .rst_n(rst_n), .tick_1khz(tick_1khz),
                             .btn_in(btn_col), .pulse(col_pulse));
    debounce_1shot u_db_sel (.clk(clk_50mhz), .rst_n(rst_n), .tick_1khz(tick_1khz),
                             .btn_in(btn_sel), .pulse(sel_pulse));

    // ---------------- Cursor (0..3 wrap) ----------------
    logic [1:0] sel_row, sel_col;
    logic       row_go,  col_go,  sel_go;

    cursor_2btn u_cursor (
        .clk      (clk_50mhz),
        .rst_n    (rst_n),
        .row_pulse(row_go),
        .col_pulse(col_go),
        .sel_row  (sel_row),
        .sel_col  (sel_col)
    );

    logic [3:0] sel_idx;
    assign sel_idx = {sel_row, sel_col};

    // ---------------- Board + shuffle ----------------
    localparam int N_CARDS = 16;
    localparam int IDX_W   = 4;

    logic [N_CARDS-1:0] matched_mask, revealed_mask;
    logic [IDX_W-1:0]   last_rev1;
    logic               have_rev1;
    logic               idx_is_valid, match_equal, all_paired;

    logic             reveal_pulse_fsm;   // from FSM
    logic [IDX_W-1:0] idx_reveal;
    logic             pair_mark_pulse_fsm;// from FSM

    // Seed: free-run; first shuffle delayed 50 ms for per-reset randomness
    logic [15:0] rand_seed;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) rand_seed <= 16'hACE1;
        else        rand_seed <= rand_seed + 16'h0041;
    end

    // 50 ms delayed startup shuffle
    logic [5:0] startup_cnt;
    logic       startup_armed, startup_shuffle;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin
            startup_cnt     <= 6'd0;
            startup_armed   <= 1'b1;
            startup_shuffle <= 1'b0;
        end else begin
            startup_shuffle <= 1'b0;
            if (startup_armed && tick_1khz) begin
                if (startup_cnt==6'd49) begin
                    startup_shuffle <= 1'b1; // one-cycle pulse
                    startup_armed   <= 1'b0;
                end else begin
                    startup_cnt <= startup_cnt + 6'd1;
                end
            end
        end
    end

    // VSYNC settle after shuffle → ready_after_shuffle
    logic vsync_q; wire vsync_rise;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) vsync_q<=1'b1; else vsync_q<=vga_vsync;
    end
    assign vsync_rise = vga_vsync & ~vsync_q;

    logic [1:0] vs_cnt;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) vs_cnt<=2'd0;
        else if (shuffle_pulse_w) vs_cnt <= 2'd0;
        else if (vsync_rise && (vs_cnt!=2'd2)) vs_cnt <= vs_cnt + 2'd1;
    end
    wire ready_after_shuffle = (vs_cnt==2'd2);

    // Mini mismatch timer (~0.6 s) with proper "active" flag
    logic mini_start, mini_done, mini_active;
    timer_down #(.WIDTH(8)) u_mini (
        .clk(clk_50mhz), .rst_n(rst_n),
        .tick(tick_100hz),
        .start(mini_start),
        .reload(mini_start),
        .stop  (mini_done),
        .preload(8'd60),
        .done(mini_done),
        .value()
    );
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) mini_active <= 1'b0;
        else begin
            if (mini_start) mini_active <= 1'b1;
            if (mini_done)  mini_active <= 1'b0;
        end
    end

    // Match-hold (~0.3 s)
    localparam [7:0] MATCH_HOLD_TICKS = 8'd30;
    logic        mh_active;
    logic [7:0]  mh_cnt;
    logic        pair_mark_match_hold;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin
            mh_active <= 1'b0; mh_cnt <= 8'd0; pair_mark_match_hold <= 1'b0;
        end else begin
            pair_mark_match_hold <= 1'b0;
            if (pair_mark_pulse_fsm & match_equal & ~mh_active) begin
                mh_active <= 1'b1; mh_cnt <= MATCH_HOLD_TICKS;
            end
            if (mh_active && tick_100hz && (mh_cnt!=8'd0)) mh_cnt <= mh_cnt - 8'd1;
            if (mh_active && (mh_cnt==8'd0)) begin
                pair_mark_match_hold <= 1'b1; mh_active <= 1'b0;
            end
        end
    end

    // Gameover edge
    logic gameover, gameover_q;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) gameover_q<=1'b0; else gameover_q<=gameover;
    end
    wire gameover_rise = gameover & ~gameover_q;

    // ---------------- Controls (responsive) ----------------
    // second revealed detection
    wire [15:0] mask_last1 = (16'h0001 << last_rev1);
    wire        second_revealed_any    = |(revealed_mask & ~mask_last1);
    wire        less_than_two_revealed = ~(have_rev1 & second_revealed_any);

    // Row/Col: responsive after shuffle; Select only when safe
    assign row_go = row_pulse & ready_after_shuffle & ~mh_active;
    assign col_go = col_pulse & ready_after_shuffle & ~mh_active;
    assign sel_go = sel_pulse & ready_after_shuffle & ~mh_active & ~mini_active & less_than_two_revealed;

    // ---------------- The "thinking window" (idle_window) ----------------
    // We are ACTUALLY waiting for a pick when Select is legally allowed.
    wire idle_window = ready_after_shuffle & ~mh_active & ~mini_active & less_than_two_revealed;

    // Edges
    logic idle_q;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) idle_q <= 1'b0;
        else        idle_q <= idle_window;
    end
    wire idle_rise =  idle_window & ~idle_q;
    wire idle_fall = ~idle_window &  idle_q;

    // ---------------- One-time first-turn shuffle flag ----------------
    logic did_first_shuffle;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin
            did_first_shuffle <= 1'b0;
        end else begin
            // Clear flag on new game context
            if (startup_shuffle || gameover_rise)
                did_first_shuffle <= 1'b0;
            // Latch after firing first-turn shuffle
            if (first_turn_shuffle)
                did_first_shuffle <= 1'b1;
        end
    end

    // ---------------- Board instance & helpers ----------------
    // Mismatch safety auto-cover
    wire pair_mark_auto =
        have_rev1 & revealed_mask[last_rev1] &
        second_revealed_any & (~match_equal) & mini_done;

    wire pair_mark_pulse_g = pair_mark_match_hold | pair_mark_auto | (pair_mark_pulse_fsm & ~match_equal);
    wire reveal_pulse_g    = reveal_pulse_fsm & ready_after_shuffle;

    // Shuffle conditions:
    //  - startup (after 50ms seed warmup)
    //  - first thinking window on an empty board (once per game)
    //  - gameover
    wire board_empty        = (matched_mask=='0) && (revealed_mask=='0) && ~have_rev1;
    wire first_turn_shuffle = idle_rise & board_empty & ~did_first_shuffle;
    wire shuffle_pulse_w    = startup_shuffle | first_turn_shuffle | gameover_rise;

    mem_board #(.N_CARDS(N_CARDS), .IDX_W(IDX_W)) u_board (
        .clk(clk_50mhz), .rst_n(rst_n),
        .query_idx(sel_idx),
        .idx_is_valid(idx_is_valid),
        .reveal_pulse   (reveal_pulse_g),
        .idx_reveal     (idx_reveal),
        .pair_mark_pulse(pair_mark_pulse_g),
        .shuffle_pulse  (shuffle_pulse_w),
        .shuffle_seed   (rand_seed),
        .matched_mask (matched_mask),
        .revealed_mask(revealed_mask),
        .last_rev1    (last_rev1),
        .have_rev1    (have_rev1),
        .symbol_id(), // not used by renderer
        .match_equal(match_equal),
        .all_paired(all_paired)
    );

    // ---------------- FSM (authoritative) ----------------
    logic [3:0] fsm_state;
    logic [1:0] cur_player;
    logic       score_inc_pulse;
    logic [1:0] winner;

    // 15s timer handshake signals from FSM
    logic t15_start, t15_reload, t15_stop;

    // Declare t15_done before using
    logic t15_done;

    mem_fsm #(.N_CARDS(N_CARDS), .IDX_W(IDX_W)) u_fsm (
        .clk   (clk_50mhz), .rst_n (rst_n),

        .pick_valid(sel_go),
        .pick_idx  (sel_idx),

        .idx_is_valid(idx_is_valid),
        .match_equal (match_equal),
        .all_paired  (all_paired),

        .auto_valid(auto_valid),
        .auto_idx  (auto_idx),

        // 15s timer handshake:
        // mask "done" by the real thinking window so it cannot expire mid-pick
        .timer15_done (t15_done & idle_window),
        .timer15_start(t15_start),
        .timer15_reload(t15_reload),
        .timer15_stop (t15_stop),

        .mini_done (mini_done),
        .mini_start(mini_start),

        .reveal_pulse   (reveal_pulse_fsm),
        .idx_reveal     (idx_reveal),
        .pair_mark_pulse(pair_mark_pulse_fsm),

        .cur_player     (cur_player),
        .score_inc_pulse(score_inc_pulse),
        .gameover       (gameover),
        .winner         (winner),

        .fsm_state      (fsm_state)
    );
    assign fsm_state_leds = fsm_state;

    // ---------------- 15s timer (FSM + window-edge fallbacks) ----------------
    logic [7:0] t15_value; logic t15_running;

    // Allow FSM to drive; also start/reload on thinking-window rise, stop on fall
    wire t15_start_d  = t15_start  | idle_rise;
    wire t15_reload_d = t15_reload | idle_rise;
    wire t15_stop_d   = t15_stop   | idle_fall;

    timer_down #(.WIDTH(8)) u_t15 (
        .clk(clk_50mhz), .rst_n(rst_n),
        .tick(tick_1hz),
        .start (t15_start_d),
        .reload(t15_reload_d),
        .stop  (t15_stop_d),
        .preload(8'd15),
        .done  (t15_done),
        .value (t15_value)
    );
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) t15_running <= 1'b0;
        else if (t15_start_d || t15_reload_d) t15_running <= 1'b1;
        else if (t15_stop_d)                  t15_running <= 1'b0;
    end

    // ---------------- Autopick (fires at 0s while waiting) ----------------
    logic        auto_valid_raw; logic [3:0] auto_idx;
    autopick #(.N_CARDS(N_CARDS), .IDX_W(IDX_W)) u_auto (
        .clk(clk_50mhz), .rst_n(rst_n),
        .timer15_done(t15_done & idle_window), // only while waiting
        .matched_mask(matched_mask),
        .revealed_mask(revealed_mask),
        .exclude_valid(have_rev1),
        .exclude_idx(last_rev1),
        .auto_valid(auto_valid_raw),
        .auto_idx  (auto_idx)
    );
    wire auto_valid = auto_valid_raw & idle_window;

    // ---------------- Player LEDs ----------------
    assign led_player1 = (cur_player == 2'd0) & ~gameover;
    assign led_player2 = (cur_player == 2'd1) & ~gameover;

    // ---------------- Renderer + overlay ----------------
    logic [7:0] base_r, base_g, base_b;
    grid_renderer_icons u_ren (
        .video_on(video_on), .x(x), .y(y),
        .sel_row(sel_row), .sel_col(sel_col),
        .R(base_r), .G(base_g), .B(base_b)
    );

    // Layout numbers
    localparam int FRAME=16, GRID_W=640-2*FRAME, GRID_H=480-2*FRAME;
    localparam int GUTTER=8, CARD_W=(GRID_W-3*GUTTER)/4, CARD_H=(GRID_H-3*GUTTER)/4;
    localparam int CELL_W=CARD_W+GUTTER, CELL_H=CARD_H+GUTTER, BORDER=3;

    localparam logic [7:0] GRAY_R=8'd200, GRAY_G=8'd200, GRAY_B=8'd200;
    localparam logic [7:0] BROWN_R=8'd160, BROWN_G=8'd110, BROWN_B=8'd50;
    localparam logic [7:0] BLACK_R=8'd0, BLACK_G=8'd0, BLACK_B=8'd0;

    logic in_frame; assign in_frame = (x>=FRAME)&&(x<FRAME+GRID_W)&&(y>=FRAME)&&(y<FRAME+GRID_H);

    logic [9:0] gx, gy; assign gx = x - FRAME; assign gy = y - FRAME;
    logic [1:0] card_c, card_r; assign card_c = gx / CELL_W; assign card_r = gy / CELL_H;
    logic [8:0] lx; logic [7:0] ly; assign lx = gx - card_c*CELL_W; assign ly = gy - card_r*CELL_H;

    logic in_card_rect; assign in_card_rect = (lx < CARD_W) && (ly < CARD_H);
    logic sel_border;
    assign sel_border = (card_r==sel_row)&&(card_c==sel_col)&&in_card_rect &&
                        ( (lx<BORDER)||(lx>=CARD_W-BORDER)||(ly<BORDER)||(ly>=CARD_H-BORDER) );

    logic [3:0] pix_idx; assign pix_idx = {card_r,card_c};

    always_comb begin
        vga_r=base_r; vga_g=base_g; vga_b=base_b;
        if (!video_on) begin
            vga_r=BLACK_R; vga_g=BLACK_G; vga_b=BLACK_B;
        end else if (in_frame && in_card_rect && !sel_border) begin
            if (!revealed_mask[pix_idx]) begin
                if (matched_mask[pix_idx]) begin
                    vga_r=BROWN_R; vga_g=BROWN_G; vga_b=BROWN_B; // matched face-down
                end else begin
                    vga_r=GRAY_R;  vga_g=GRAY_G;  vga_b=GRAY_B;  // unmatched face-down
                end
            end else if (matched_mask[pix_idx]) begin
                // matched while revealed (during hold): dim
                vga_r={1'b0,base_r[7:1]}; vga_g={1'b0,base_g[7:1]}; vga_b={1'b0,base_b[7:1]};
            end
        end
    end

    // ---------------- 7-seg (active-low) ----------------
    logic [7:0] disp_t;
    always_comb begin
        disp_t = (t15_running) ? t15_value : 8'd15;
        if (disp_t > 8'd15) disp_t = 8'd15;
    end

    logic [3:0] t_tens, t_ones;
    always_comb begin
        if (disp_t >= 8'd10) begin t_tens=4'd1; t_ones=disp_t-8'd10; end
        else begin t_tens=4'd0; t_ones=disp_t[3:0]; end
    end

    sevenseg_hex6 #(
  .ACTIVE_LOW_7SEG(ACTIVE_LOW_7SEG),
  .REVERSE_SEG_ORDER(REVERSE_SEG_ORDER)
) u_seg (
      .t_tens(t_tens), .t_ones(t_ones),
      .score_j1(score_j1), .score_j2(score_j2),
      .HEX5(HEX5), .HEX4(HEX4), .HEX3(HEX3), .HEX2(HEX2), .HEX1(HEX1), .HEX0(HEX0)
    );


    // ---------------- Scoreboard ----------------
    logic [3:0] score_j1, score_j2;
    scoreboard u_scores (
        .clk(clk_50mhz), .rst_n(rst_n),
        .cur_player(cur_player),
        .score_inc_pulse(score_inc_pulse),
        .score_j1(score_j1), .score_j2(score_j2)
    );

endmodule
`default_nettype wire
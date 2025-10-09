// =============================================================
// top_memory_game.sv  (Quartus-friendly fix)
//  - Removed declaration-time assigns for row_go/col_go/sel_go
//  - Connected mem_board ports directly (no hierarchical assigns)
//  - Removed unused symbols_bus to avoid warning
// =============================================================
module top_memory_game (
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

    // 7-seg (optional)
    output logic [6:0]  seg,
    output logic        dp,
    output logic [3:0]  an,

    // Debug
    output logic [3:0]  fsm_state_leds
);
    // --- DAC aux pins / clock ---
    assign vga_blank_n = 1'b1;
    assign vga_sync_n  = 1'b0;
    assign vga_clk     = clk_50mhz;

    // --- Pixel enable ÷2 ---
    logic pix_ce;
    pix_enable_div2 u_pixce (
        .clk_50 (clk_50mhz),
        .rst_n  (rst_n),
        .pix_ce (pix_ce)
    );

    // --- VGA timing ---
    logic        video_on;
    logic [9:0]  x, y;
    vga_timing_640x480_en u_tim (
        .clk     (clk_50mhz),
        .rst_n   (rst_n),
        .pix_ce  (pix_ce),
        .hsync   (vga_hsync),
        .vsync   (vga_vsync),
        .video_on(video_on),
        .x       (x),
        .y       (y)
    );

    // --- Ticks: 1 kHz, 100 Hz, 1 Hz ---
    logic [15:0] div1k;   logic tick_1khz;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin div1k<=0; tick_1khz<=0; end
        else if (div1k==16'd49999) begin div1k<=0; tick_1khz<=1; end
        else begin div1k<=div1k+16'd1; tick_1khz<=0; end
    end

    logic [19:0] div100;  logic tick_100hz;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin div100<=0; tick_100hz<=0; end
        else if (div100==20'd499_999) begin div100<=0; tick_100hz<=1; end
        else begin div100<=div100+20'd1; tick_100hz<=0; end
    end

    logic [25:0] div1;    logic tick_1hz;
    always_ff @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin div1<=0; tick_1hz<=0; end
        else if (div1==26'd49_999_999) begin div1<=0; tick_1hz<=1; end
        else begin div1<=div1+26'd1; tick_1hz<=0; end
    end

    // --- Debounced one-shots for the 3 buttons ---
    logic row_pulse, col_pulse, sel_pulse;
    debounce_1shot u_db_row (.clk(clk_50mhz), .rst_n(rst_n), .tick_1khz(tick_1khz),
                             .btn_in(btn_row), .pulse(row_pulse));
    debounce_1shot u_db_col (.clk(clk_50mhz), .rst_n(rst_n), .tick_1khz(tick_1khz),
                             .btn_in(btn_col), .pulse(col_pulse));
    debounce_1shot u_db_sel (.clk(clk_50mhz), .rst_n(rst_n), .tick_1khz(tick_1khz),
                             .btn_in(btn_sel), .pulse(sel_pulse));

    // --- Cursor gating based on FSM state ---
    localparam logic [3:0] S_NAV1 = 4'd2;
    localparam logic [3:0] S_NAV2 = 4'd4;

    logic [3:0] fsm_state;
    logic       allow_input;
    assign allow_input = (fsm_state == S_NAV1) || (fsm_state == S_NAV2);

    logic row_go, col_go, sel_go;      // << fixed: declare first
    assign row_go = row_pulse & allow_input;   // << fixed: separate 'assign'
    assign col_go = col_pulse & allow_input;
    assign sel_go = sel_pulse & allow_input;

    logic [1:0] sel_row, sel_col;
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

    // --- Board state (masks + symbols) ---
    localparam int N_CARDS = 16;
    localparam int IDX_W   = 4;

    logic [N_CARDS-1:0] matched_mask, revealed_mask;
    logic [IDX_W-1:0]   last_rev1;
    logic               have_rev1;
    logic               idx_is_valid, match_equal, all_paired;
    logic [3:0]         symbol_id [N_CARDS];

    // Control lines between FSM and board
    logic             reveal_pulse;
    logic [IDX_W-1:0] idx_reveal;
    logic             pair_mark_pulse;

    mem_board #(.N_CARDS(N_CARDS), .IDX_W(IDX_W)) u_board (
        .clk(clk_50mhz),
        .rst_n(rst_n),

        .query_idx(sel_idx),
        .idx_is_valid(idx_is_valid),

        .reveal_pulse   (reveal_pulse),     // << fixed: connected directly
        .idx_reveal     (idx_reveal),
        .pair_mark_pulse(pair_mark_pulse),

        .matched_mask (matched_mask),
        .revealed_mask(revealed_mask),
        .last_rev1    (last_rev1),
        .have_rev1    (have_rev1),

        .symbol_id(symbol_id),

        .match_equal(match_equal),
        .all_paired(all_paired)
    );

    // --- Timers ---
    logic t15_start, t15_reload, t15_stop, t15_done;
    logic [15:0] t15_value;
    timer_down #(.WIDTH(8)) u_t15 (
        .clk(clk_50mhz), .rst_n(rst_n),
        .tick(tick_1hz),
        .start(t15_start),
        .reload(t15_reload),
        .stop(t15_stop),
        .preload(8'd15),
        .done(t15_done),
        .value(t15_value)
    );

    logic mini_start, mini_done;
    logic [7:0] mini_value;
    timer_down #(.WIDTH(8)) u_mini (
        .clk(clk_50mhz), .rst_n(rst_n),
        .tick(tick_100hz),
        .start(mini_start),
        .reload(mini_start),
        .stop  (mini_done),
        .preload(8'd60),       // ~0.6 s at 100 Hz
        .done(mini_done),
        .value(mini_value)
    );

    // --- Autopick ---
    logic        auto_valid;
    logic [3:0]  auto_idx;
    autopick #(.N_CARDS(N_CARDS), .IDX_W(IDX_W)) u_auto (
        .clk(clk_50mhz),
        .rst_n(rst_n),
        .timer15_done(t15_done),
        .matched_mask(matched_mask),
        .revealed_mask(revealed_mask),
        .exclude_valid(have_rev1),
        .exclude_idx(last_rev1),
        .auto_valid(auto_valid),
        .auto_idx  (auto_idx)
    );

    // --- Game FSM ---
    logic [1:0] cur_player;
    logic       score_inc_pulse;
    logic       gameover;
    logic [1:0] winner;

    mem_fsm #(.N_CARDS(N_CARDS), .IDX_W(IDX_W)) u_fsm (
        .clk   (clk_50mhz),
        .rst_n (rst_n),

        .pick_valid(sel_go),
        .pick_idx  (sel_idx),

        .idx_is_valid(idx_is_valid),
        .match_equal (match_equal),
        .all_paired  (all_paired),

        .auto_valid(auto_valid),
        .auto_idx  (auto_idx),

        .timer15_done (t15_done),
        .timer15_start(t15_start),
        .timer15_reload(t15_reload),
        .timer15_stop (t15_stop),

        .mini_done (mini_done),
        .mini_start(mini_start),

        .reveal_pulse   (reveal_pulse),
        .idx_reveal     (idx_reveal),
        .pair_mark_pulse(pair_mark_pulse),

        .cur_player     (cur_player),
        .score_inc_pulse(score_inc_pulse),
        .gameover       (gameover),
        .winner         (winner),

        .fsm_state      (fsm_state)
    );

    assign fsm_state_leds = fsm_state;

    // --- Scoreboard + 7seg (optional) ---
    logic [3:0] score_j1, score_j2;
    scoreboard u_scores (
        .clk(clk_50mhz), .rst_n(rst_n),
        .cur_player(cur_player),
        .score_inc_pulse(score_inc_pulse),
        .score_j1(score_j1),
        .score_j2(score_j2)
    );

    sevenseg_mux4 #(.AN_ACTIVE_LOW(1)) u_7seg (
        .clk(clk_50mhz), .rst_n(rst_n),
        .d0(score_j1), .d1(4'd0), .d2(score_j2), .d3(4'd0),
        .dp_mask(4'b0000),
        .seg(seg), .dp(dp), .an(an)
    );

    // --- Base renderer (unchanged) ---
    logic [7:0] base_r, base_g, base_b;
    grid_renderer_icons u_ren (
        .video_on(video_on),
        .x       (x),
        .y       (y),
        .sel_row (sel_row),
        .sel_col (sel_col),
        .R       (base_r),
        .G       (base_g),
        .B       (base_b)
    );

    // --- Overlay to reflect game masks (face-down / matched dim) ---
    localparam int FRAME   = 16;
    localparam int GRID_W  = 640 - 2*FRAME;     // 608
    localparam int GRID_H  = 480 - 2*FRAME;     // 448
    localparam int GUTTER  = 8;
    localparam int CARD_W  = (GRID_W - 3*GUTTER)/4;  // 146
    localparam int CARD_H  = (GRID_H - 3*GUTTER)/4;  // 106
    localparam int CELL_W  = CARD_W + GUTTER;        // 154
    localparam int CELL_H  = CARD_H + GUTTER;        // 114
    localparam int BORDER  = 3;

    logic in_frame;
    assign in_frame = (x >= FRAME) && (x < FRAME + GRID_W) &&
                      (y >= FRAME) && (y < FRAME + GRID_H);

    logic [9:0] gx, gy; assign gx = x - FRAME; assign gy = y - FRAME;
    logic [1:0] card_c, card_r;
    assign card_c = gx / CELL_W;
    assign card_r = gy / CELL_H;

    logic [8:0] lx; logic [7:0] ly;
    assign lx = gx - card_c * CELL_W;
    assign ly = gy - card_r * CELL_H;

    logic in_card_rect;
    assign in_card_rect = (lx < CARD_W) && (ly < CARD_H);

    logic sel_border;
    assign sel_border = (card_r==sel_row) && (card_c==sel_col) && in_card_rect &&
                        ((lx < BORDER) || (lx >= CARD_W - BORDER) ||
                         (ly < BORDER) || (ly >= CARD_H - BORDER));

    logic [3:0] pix_idx;
    assign pix_idx = {card_r, card_c};

    localparam logic [7:0] GRAY_FRAME_R = 8'd48,  GRAY_FRAME_G = 8'd48,  GRAY_FRAME_B = 8'd48;
    localparam logic [7:0] GRAY_CARD_R  = 8'd200, GRAY_CARD_G  = 8'd200, GRAY_CARD_B  = 8'd200;
    localparam logic [7:0] BLACK_R      = 8'd0,   BLACK_G      = 8'd0,   BLACK_B      = 8'd0;

    always_comb begin
        vga_r = base_r; vga_g = base_g; vga_b = base_b;

        if (!video_on) begin
            vga_r = BLACK_R; vga_g = BLACK_G; vga_b = BLACK_B;
        end
        else if (in_frame && in_card_rect && !sel_border) begin
            if (!revealed_mask[pix_idx]) begin
                vga_r = GRAY_CARD_R; vga_g = GRAY_CARD_G; vga_b = GRAY_CARD_B; // face-down
            end
            else if (matched_mask[pix_idx]) begin
                vga_r = {1'b0, base_r[7:1]}; // dim 50%
                vga_g = {1'b0, base_g[7:1]};
                vga_b = {1'b0, base_b[7:1]};
            end
        end
    end
endmodule

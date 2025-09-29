// top_memory_grid.sv
// 50 MHz system; VGA 640x480@60 via pixel-enable ÷2 (no extra PLL).
// HS/VS active-low. Outputs include VGA_CLK (to the DAC), BLANK_N=1, SYNC_N=0.
// Buttons: btn_row advances row (0..3), btn_col advances col (0..3). rst_n is active-low.

module top_memory_grid (
    input  logic        clk_50mhz,
    input  logic        rst_n,
    input  logic        btn_row,
    input  logic        btn_col,
    output logic        vga_hsync,
    output logic        vga_vsync,
    output logic [7:0]  vga_r,
    output logic [7:0]  vga_g,
    output logic [7:0]  vga_b,
    output logic        vga_blank_n,
    output logic        vga_sync_n,
    output logic        vga_clk
);
    // --- DAC control / clock ---
    assign vga_blank_n = 1'b1;       // enable DAC outputs
    assign vga_sync_n  = 1'b0;       // no composite sync
    assign vga_clk     = clk_50mhz;  // many VGA DACs require a pixel clock input

    // --- Pixel enable (~25 MHz effective) ---
    logic pix_ce;
    pix_enable_div2 u_pixce (
        .clk_50 (clk_50mhz),
        .rst_n  (rst_n),
        .pix_ce (pix_ce)
    );

    // --- VGA timing (counters tick only when pix_ce=1) ---
    logic        video_on;
    logic [9:0]  x, y;
    vga_timing_640x480_en u_tim (
        .clk     (clk_50mhz),
        .rst_n   (rst_n),
        .pix_ce  (pix_ce),
        .hsync   (vga_hsync),    // active low
        .vsync   (vga_vsync),    // active low
        .video_on(video_on),
        .x       (x),
        .y       (y)
    );

    // --- Debounced one-shots from push-buttons ---
    logic row_pulse, col_pulse;
    btn_one_pulse #(.CNTR_BITS(19)) u_db_row ( // ~10ms @ 50MHz
        .clk    (clk_50mhz),
        .rst_n  (rst_n),
        .btn_raw(btn_row),
        .pulse  (row_pulse)
    );
    btn_one_pulse #(.CNTR_BITS(19)) u_db_col (
        .clk    (clk_50mhz),
        .rst_n  (rst_n),
        .btn_raw(btn_col),
        .pulse  (col_pulse)
    );

    // --- 2-button cursor (wraps 3->0) ---
    logic [1:0] sel_row, sel_col;
    cursor_2btn u_cursor (
        .clk      (clk_50mhz),
        .rst_n    (rst_n),
        .row_pulse(row_pulse),
        .col_pulse(col_pulse),
        .sel_row  (sel_row),
        .sel_col  (sel_col)
    );

    // --- Renderer: gray frame + gutters + 4x4 cards with procedural icons ---
    grid_renderer_icons u_ren (
        .video_on(video_on),
        .x       (x),
        .y       (y),
        .sel_row (sel_row),
        .sel_col (sel_col),
        .R       (vga_r),
        .G       (vga_g),
        .B       (vga_b)
    );
endmodule

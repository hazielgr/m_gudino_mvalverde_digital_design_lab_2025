// vga_timing_640x480_en.sv
module vga_timing_640x480_en (
    input  logic        clk,     // 50 MHz
    input  logic        rst_n,
    input  logic        pix_ce,  // enable ~25 MHz
    output logic        hsync,   // activo en bajo
    output logic        vsync,   // activo en bajo
    output logic        video_on,
    output logic [9:0]  x,       // 0..639
    output logic [9:0]  y        // 0..479
);
    localparam H_VISIBLE=640, H_FRONT=16, H_SYNC=96, H_BACK=48, H_TOTAL=800;
    localparam V_VISIBLE=480, V_FRONT=10, V_SYNC=2,  V_BACK=33, V_TOTAL=525;

    logic [9:0] h_cnt, v_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_cnt <= '0; v_cnt <= '0;
        end else if (pix_ce) begin
            if (h_cnt == H_TOTAL-1) begin
                h_cnt <= 10'd0;
                v_cnt <= (v_cnt == V_TOTAL-1) ? 10'd0 : v_cnt + 10'd1;
            end else begin
                h_cnt <= h_cnt + 10'd1;
            end
        end
    end

    assign hsync    = ~((h_cnt >= H_VISIBLE + H_FRONT) && (h_cnt < H_VISIBLE + H_FRONT + H_SYNC));
    assign vsync    = ~((v_cnt >= V_VISIBLE + V_FRONT) && (v_cnt < V_VISIBLE + V_FRONT + V_SYNC));
    assign video_on = (h_cnt < H_VISIBLE) && (v_cnt < V_VISIBLE);
    assign x = h_cnt;
    assign y = v_cnt;
endmodule

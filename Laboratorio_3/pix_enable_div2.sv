// pix_enable_div2.sv
module pix_enable_div2 (
    input  logic clk_50,
    input  logic rst_n,
    output logic pix_ce
);
    logic toggle;
    always_ff @(posedge clk_50 or negedge rst_n) begin
        if (!rst_n) toggle <= 1'b0;
        else        toggle <= ~toggle;
    end
    assign pix_ce = toggle; // 1 un ciclo sí / un ciclo no
endmodule

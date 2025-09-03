module one_pulse (
    input  logic clk,
    input  logic rst_n,     // reset síncrono
    input  logic level_in,  // nivel estable 
    output logic pulse_out  // pulso de 1 ciclo por cada 0->1
);
    logic level_d;
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            level_d   <= 1'b0;
            pulse_out <= 1'b0;
        end else begin
            pulse_out <= level_in & ~level_d; 
            level_d   <= level_in;
        end
    end
endmodule

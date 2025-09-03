module counter #(
    parameter int N = 6
)(
    input  logic         clk,
    input  logic         arst_n,     // reset asíncrono 
    input  logic         enable,     // suma +1 cuando está en 1 un ciclo
    input  logic         load,       
    input  logic [N-1:0] load_value,
    output logic [N-1:0] q
);
    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n)      q <= '0;
        else if (load)    q <= load_value;
        else if (enable)  q <= q + 1'b1;  
    end
endmodule

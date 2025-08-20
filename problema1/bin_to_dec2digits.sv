

module bin_to_dec2digits (
    input  logic [3:0] bin,      
    output logic [3:0] tens,     
    output logic [3:0] ones      
);
    logic        ge10;           
    logic [3:0]  base10;

    always_comb begin
        
        ge10   = (bin >= 4'd10);
        tens   = ge10 ? 4'd1 : 4'd0;

        
        base10 = ge10 ? 4'd10 : 4'd0;
        ones   = bin - base10;   
    end
endmodule

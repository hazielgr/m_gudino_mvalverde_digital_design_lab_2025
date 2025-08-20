// ---------------------------------------------------------------
// bin_to_dec2digits.sv  —  0..15 (bin) → decenas/unidades decimales
// Sin usar 'case' gigante para BCD. Lógica simple aritmética/booleana.
// ---------------------------------------------------------------
module bin_to_dec2digits (
    input  logic [3:0] bin,      // valor 0..15
    output logic [3:0] tens,     // 0..1
    output logic [3:0] ones      // 0..9
);
    logic        ge10;           // bin >= 10 ?
    logic [3:0]  base10;

    always_comb begin
        
        ge10   = (bin >= 4'd10);
        tens   = ge10 ? 4'd1 : 4'd0;

        
        base10 = ge10 ? 4'd10 : 4'd0;
        ones   = bin - base10;   // 0..9
    end
endmodule

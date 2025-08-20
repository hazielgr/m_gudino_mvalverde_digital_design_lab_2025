
module top_lab1_ej1 (
    input  logic [3:0] SW,            // switches físicos
    output logic [6:0] HEX1,          // decenas
    output logic [6:0] HEX0           // unidades
    
);
    // señales
    logic [3:0] B;
    logic [3:0] G;
    logic [3:0] tens, ones;

    // conexión de entrada
    assign B = SW;

    //  calcular Gray 
    bin2gray u_bin2gray (
        .B (B),
        .G (G)
    );

    
    bin_to_dec2digits u_b2d (
        .bin  (B),
        .tens (tens),
        .ones (ones)
    );

    
    seven_seg_decoder u_dec_tens (
        .digit (tens),
        .seg   (HEX1)
    );

    seven_seg_decoder u_dec_ones (
        .digit (ones),
        .seg   (HEX0)
    );

   
endmodule

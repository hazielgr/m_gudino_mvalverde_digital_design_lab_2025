module bin_to_dec2digits (
    input  logic [5:0] bin,   
    output logic [3:0] tens,  // decenas
    output logic [3:0] ones   // unidades
);
    logic [6:0] v;
    assign v    = bin;
    assign tens = v / 10;   // división entera
    assign ones = v % 10;   // residuo
endmodule

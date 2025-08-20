// -------------------------------------------
// bin2gray.sv  —  Conversor Binario (4 bits) → Gray (4 bits)
// -------------------------------------------
module bin2gray (
    input  logic [3:0] B,   // B3 B2 B1 B0
    output logic [3:0] G    // G3 G2 G1 G0
);

    always_comb begin
        G[3] = B[3];
        G[2] = B[3] ^ B[2];
        G[1] = B[2] ^ B[1];
        G[0] = B[1] ^ B[0];
    end
endmodule

module sumador_Nbits #(parameter int P=4)(
    input  logic [P-1:0] a, b,
    input  logic cin,
    output logic [P-1:0] sum,
    output logic cout, N, Z, C, V
);

    logic [P:0] carry;
    logic [P-1:0] sum_bits;
    assign carry[0] = cin;

    genvar i;
    generate
        for(i=0;i<P;i=i+1) begin : SUM_BIT
            sumador_1bit u1(
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum_bits[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    assign cout = carry[P];          // carry final
    assign C    = carry[P];          // carry final
    assign V    = carry[P];          // overflow = carry si la suma excede P bits
    assign Z    = (sum_bits == 0);   // resultado cero
    assign N    = 0;                 // suma siempre positiva

    // resultado truncado o cero si overflow
    assign sum = V ? {P{1'b0}} : sum_bits;

endmodule




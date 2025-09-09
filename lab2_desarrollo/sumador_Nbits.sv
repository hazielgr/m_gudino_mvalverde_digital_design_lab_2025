module sumador_Nbits #(parameter int P=4)(
    input  logic [P-1:0] a, b,
    input  logic cin,
    output logic [P-1:0] sum,
    output logic cout, N, Z, C, V
);

    logic [P:0] carry;
    logic [P:0] tmp_sum; // resultado extendido para overflow
    assign carry[0] = cin;

    genvar i;
    generate
        for(i=0;i<P;i=i+1) begin : SUM_BIT
            sumador_1bit u1(
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(),       // usamos temporal
                .cout(carry[i+1])
            );
        end
    endgenerate

    // resultado extendido para overflow real
    assign tmp_sum = {1'b0,a} + {1'b0,b} + cin;

    // banderas según tus reglas
    assign cout = carry[P];             
    assign C    = (tmp_sum > {1'b0,{P{1'b1}}}); // carry si hubo overflow
    assign V    = (tmp_sum > {1'b0,{P{1'b1}}}); // overflow si excede P bits
    assign Z    = (tmp_sum[P-1:0] == 0);
    assign N    = 0; // suma siempre positiva según tus reglas

    // Resultado truncado: si overflow, sum = 0, si no, sum = P bits
    assign sum = V ? {P{1'b0}} : tmp_sum[P-1:0];

endmodule




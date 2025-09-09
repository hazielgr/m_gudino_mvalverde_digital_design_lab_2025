module restador_Nbits #(parameter int P=4)(
    input  logic [P-1:0] a, b,
    input  logic bin,  // borrow in inicial
    output logic [P-1:0] diff,
    output logic bout, // borrow final
    output logic N, Z, C, V
);
    logic [P:0] borrow;
    logic [P-1:0] temp_diff;
    logic borrow_flag;
    
    assign borrow[0] = bin;

    genvar i;
    generate
        for(i=0;i<P;i=i+1) begin : SUB_BIT
            restador_1bit u1(
                .a(a[i]),
                .b(b[i]),
                .bin(borrow[i]),
                .diff(temp_diff[i]),
                .bout(borrow[i+1])
            );
        end
    endgenerate

    assign borrow_flag = (a < b);  // indica si la resta real es negativa
    assign diff = borrow_flag ? (~temp_diff+1) : temp_diff;

    assign N = borrow_flag;         // 1 si resultado real negativo
    assign Z = (diff == 0);
    assign C = ~borrow_flag;        // 1 si no hubo borrow
    assign V = 0;        
    assign bout = borrow[P];        // borrow final
endmodule

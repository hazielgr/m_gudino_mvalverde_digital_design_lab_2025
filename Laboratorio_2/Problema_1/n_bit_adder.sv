`include "full_adder.sv"

module n_bit_adder #(
  parameter int N = 4
)(
  input  logic [N-1:0] A, B,
  input  logic         Cin,
  output logic [N-1:0] S,
  output logic         Cout
);
  logic [N:0] c;
  assign c[0] = Cin;

  genvar i;
  generate
    for (i = 0; i < N; i++) begin : GEN_FA
      full_adder_tt fa(
        .a(A[i]), .b(B[i]), .cin(c[i]),
        .sum(S[i]), .cout(c[i+1])
      );
    end
  endgenerate

  assign Cout = c[N];
endmodule

`include "n_bit_adder.sv"

module n_bit_subtractor #(
  parameter int N = 4
)(
  input  logic [N-1:0] A, B,
  output logic [N-1:0] D,
  output logic         Cout  // -> usar como C = ¬borrow
);
  logic [N-1:0] Bn = ~B;

  n_bit_adder #(.N(N)) add(
    .A(A), .B(Bn), .Cin(1'b1),
    .S(D), .Cout(Cout)
  );
endmodule

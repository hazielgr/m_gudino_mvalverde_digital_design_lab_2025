module n_bit_or #(
  parameter int N = 4
)(
  input  logic [N-1:0] A, B,
  output logic [N-1:0] Y
);
  genvar i;
  generate for (i=0; i<N; i++) begin : G
    or1 u (.a(A[i]), .b(B[i]), .y(Y[i]));
  end endgenerate
endmodule

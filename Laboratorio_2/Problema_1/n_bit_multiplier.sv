

module n_bit_multiplier #(
  parameter int N = 4
)(
  input  logic [N-1:0] A, B,
  output logic [2*N-1:0] P
);
  logic [N-1:0] pp [N-1:0];
  logic [2*N-1:0] sum [N:0];
  logic [2*N-1:0] shifted_pp [N-1:0];

  genvar i, j;
  // productos parciales con and1 (tabla de verdad)
  generate
    for (i = 0; i < N; i++) begin : ROW
      for (j = 0; j < N; j++) begin : COL
        and1 a1(.a(A[j]), .b(B[i]), .y(pp[i][j]));
      end
      for (j = 0; j < 2*N; j++) begin : SH
        if (j < i) assign shifted_pp[i][j] = 1'b0;
        else if (j < i+N) assign shifted_pp[i][j] = pp[i][j-i];
        else assign shifted_pp[i][j] = 1'b0;
      end
    end
  endgenerate

  assign sum[0] = '0;

  generate
    for (i = 0; i < N; i++) begin : ACC
      logic [N-1:0] lo_s, hi_s;
      logic c_lo, c_hi;
      n_bit_adder #(.N(N)) ADD_LO (
        .A(sum[i][N-1:0]),
        .B(shifted_pp[i][N-1:0]),
        .Cin(1'b0),
        .S(lo_s), .Cout(c_lo)
      );
      n_bit_adder #(.N(N)) ADD_HI (
        .A(sum[i][2*N-1:N]),
        .B(shifted_pp[i][2*N-1:N]),
        .Cin(c_lo),
        .S(hi_s), .Cout(c_hi)
      );
      assign sum[i+1] = {hi_s, lo_s};
    end
  endgenerate

  assign P = sum[N];
endmodule

module divisor #(
  parameter int N = 4
)(
  input  logic [N-1:0] A, B,
  output logic [N-1:0] Q
);
  always_comb begin
    Q = (B != '0) ? (A / B) : '0; 
  end
endmodule

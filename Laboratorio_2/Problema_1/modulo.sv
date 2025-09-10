module modulo #(
  parameter int N = 4
)(
  input  logic [N-1:0] A, B,
  output logic [N-1:0] R
);
  always_comb begin
    R = (B != '0) ? (A % B) : A; 
  end
endmodule

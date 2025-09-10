module shifter #(
  parameter int N = 4
)(
  input  logic [N-1:0] A,
  input  logic         DIR,                     // 1 = left, 0 = right
  input  logic [$clog2(N)-1:0] SHAMT,
  output logic [N-1:0] R,
  output logic         C_out                    // bit expulsado "final"
);
  function automatic logic shift_carry_left (input logic [N-1:0] X, input int unsigned k);
    if (k==0) return 1'b0; else return X[N-1-(k-1)];
  endfunction
  function automatic logic shift_carry_right(input logic [N-1:0] X, input int unsigned k);
    if (k==0) return 1'b0; else return X[(k-1)];
  endfunction

  always_comb begin
    if (DIR) begin
      R     = A << SHAMT;
      C_out = shift_carry_left (A, SHAMT);
    end else begin
      R     = A >> SHAMT;
      C_out = shift_carry_right(A, SHAMT);
    end
  end
endmodule

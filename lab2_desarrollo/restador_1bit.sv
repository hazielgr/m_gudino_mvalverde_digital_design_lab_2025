
module restador_1bit (
  input  logic a,
  input  logic b,
  input  logic bin,   // borrow in
  output logic diff,
  output logic bout   // borrow out
);
  
  assign diff = (a ^ b) ^ bin;
  assign bout = ((~a) & b) | (((~(a ^ b))) & bin);
endmodule

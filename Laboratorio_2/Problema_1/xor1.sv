module xor1(
  input  logic a, b,
  output logic y
);
  always_comb begin
    unique case ({a,b})
      2'b00, 2'b11: y = 1'b0;
      2'b01, 2'b10: y = 1'b1;
    endcase
  end
endmodule

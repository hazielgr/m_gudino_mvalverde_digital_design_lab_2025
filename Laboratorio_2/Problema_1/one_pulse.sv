module one_pulse(
  input  logic clk,
  input  logic level_in,
  output logic pulse_out
);
  logic z1;
  always_ff @(posedge clk) begin
    z1 <= level_in;
    pulse_out <= level_in & ~z1;
  end
endmodule

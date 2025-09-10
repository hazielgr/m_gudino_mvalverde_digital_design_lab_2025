module bin_to_bcd #(
  parameter int WIDTH  = 8,   // bits de entrada
  parameter int DIGITS = 3    // dígitos BCD de salida
)(
  input  logic [WIDTH-1:0] bin,
  output logic [4*DIGITS-1:0] bcd
);
  integer i, d;
  logic [4*DIGITS-1:0] tmp;
  always_comb begin
    tmp = '0;
    for (i = WIDTH-1; i >= 0; i--) begin
      for (d = 0; d < DIGITS; d++) begin
        if (tmp[d*4 +: 4] >= 5) tmp[d*4 +: 4] = tmp[d*4 +: 4] + 4'd3;
      end
      tmp = {tmp[4*DIGITS-2:0], bin[i]};
    end
    bcd = tmp;
  end
endmodule

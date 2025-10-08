// =============================================================
// sevenseg_mux4: multiplexa 4 dígitos (anodos activos en bajo por defecto)
// Entradas: 4 nibbles BCD y punto decimal opcional.
// =============================================================
module sevenseg_mux4 #(
  parameter bit AN_ACTIVE_LOW = 1
)(
  input  logic clk,
  input  logic rst_n,
  input  logic [3:0] d0, d1, d2, d3,   // d0 = menos significativo
  input  logic [3:0] dp_mask,          // bit=1 -> enciende punto en ese dígito
  output logic [6:0] seg,              // a,b,c,d,e,f,g (activo en bajo)
  output logic       dp,               // punto (activo en bajo)
  output logic [3:0] an                // anodos (activo en bajo)
);
  // BCD->7seg (abcdefg) activos en bajo
  function automatic [6:0] bcd7(input [3:0] v);
    case(v)
      4'd0: bcd7 = 7'b1000000;
      4'd1: bcd7 = 7'b1111001;
      4'd2: bcd7 = 7'b0100100;
      4'd3: bcd7 = 7'b0110000;
      4'd4: bcd7 = 7'b0011001;
      4'd5: bcd7 = 7'b0010010;
      4'd6: bcd7 = 7'b0000010;
      4'd7: bcd7 = 7'b1111000;
      4'd8: bcd7 = 7'b0000000;
      4'd9: bcd7 = 7'b0010000;
      default: bcd7 = 7'b1111111;
    endcase
  endfunction

  logic [1:0] sel;
  logic [15:0] div;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin div<=16'd0; sel<=2'd0; end
    else begin
      div <= div + 16'd1;
      sel <= div[15:14]; // ~1 kHz mux si clk ≈ 50 MHz
    end
  end

  logic [3:0] nibble;
  always_comb begin
    case(sel)
      2'd0: nibble = d0;
      2'd1: nibble = d1;
      2'd2: nibble = d2;
      default: nibble = d3;
    endcase
  end

  assign seg = bcd7(nibble);
  assign dp  = dp_mask[sel] ? 1'b0 : 1'b1;   // activo en bajo

  // anodos
  wire [3:0] an_on = (4'b0001 << sel);
  assign an = AN_ACTIVE_LOW ? ~an_on : an_on;
endmodule

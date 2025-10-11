// =============================================================
// sevenseg_hex6_fromtop.sv
// Extracted from top_memory_game_hex6: encodes and routes HEX5..HEX0
// Keeps the exact behavior: ACTIVE_LOW_7SEG & REVERSE_SEG_ORDER.
// =============================================================
module sevenseg_hex6 #(
  parameter bit ACTIVE_LOW_7SEG   = 1'b1, // 1 = segments active-low (0 = ON)
  parameter bit REVERSE_SEG_ORDER = 1'b1  // 1 = output as g..a instead of a..g
)(
  input  logic [3:0] t_tens,
  input  logic [3:0] t_ones,
  input  logic [3:0] score_j1,
  input  logic [3:0] score_j2,
  output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);
  // --- Original local functions preserved as module-local ---
  function automatic logic [6:0] seg7_encode(input logic [3:0] val);
    logic [6:0] on;
    begin
      case (val)
        4'h0: on=7'b1111110; 4'h1: on=7'b0110000; 4'h2: on=7'b1101101; 4'h3: on=7'b1111001;
        4'h4: on=7'b0110011; 4'h5: on=7'b1011011; 4'h6: on=7'b1011111; 4'h7: on=7'b1110000;
        4'h8: on=7'b1111111; 4'h9: on=7'b1111011; 4'hA: on=7'b1110111; 4'hB: on=7'b0011111;
        4'hC: on=7'b1001110; 4'hD: on=7'b0111101; 4'hE: on=7'b1001111; 4'hF: on=7'b1000111;
        default: on=7'b0000000;
      endcase
      seg7_encode = (ACTIVE_LOW_7SEG) ? ~on : on;
    end
  endfunction

  function automatic logic [6:0] seg7_blank();
    logic [6:0] off;
    begin
      off = (ACTIVE_LOW_7SEG) ? ~7'b0000000 : 7'b0000000;
      seg7_blank = off;
    end
  endfunction

  function automatic logic [6:0] seg7_order(input logic [6:0] v);
    if (REVERSE_SEG_ORDER) seg7_order = {v[0],v[1],v[2],v[3],v[4],v[5],v[6]};
    else                   seg7_order = v;
  endfunction

  // --- Exact routing preserved from the top ---
  assign HEX5 = seg7_order( seg7_encode(t_tens) );
  assign HEX4 = seg7_order( seg7_encode(t_ones) );
  assign HEX3 = seg7_order( seg7_blank() );
  assign HEX2 = seg7_order( seg7_blank() );
  assign HEX1 = seg7_order( seg7_encode(score_j2) );
  assign HEX0 = seg7_order( seg7_encode(score_j1) );
endmodule

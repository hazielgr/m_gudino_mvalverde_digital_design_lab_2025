// =============================================================
// scoreboard: cuenta parejas por jugador (pulso + jugador actual)
// =============================================================
module scoreboard(
  input  logic clk,
  input  logic rst_n,
  input  logic [1:0] cur_player,     // 0=J1, 1=J2
  input  logic       score_inc_pulse,
  output logic [3:0] score_j1,       // hasta 8 pares
  output logic [3:0] score_j2
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin score_j1<=4'd0; score_j2<=4'd0; end
    else if (score_inc_pulse) begin
      if (cur_player==2'd0) score_j1 <= score_j1 + 1'b1;
      else                  score_j2 <= score_j2 + 1'b1;
    end
  end
endmodule

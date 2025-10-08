// =============================================================
// mem_board: estado del tablero (símbolos, reveladas, emparejadas)
// - Responde a pulsos de la FSM: reveal_pulse (con idx_reveal) y
//   pair_mark_pulse (con los 2 últimos revelados) para "cerrar" pareja.
// - Exporta match_equal cuando hay 2 reveladas y son iguales.
// - Exporta idx_is_valid para un pick_idx propuesto.
// =============================================================
module mem_board #(
  parameter int N_CARDS = 16,
  parameter int IDX_W   = $clog2(N_CARDS)
)(
  input  logic clk,
  input  logic rst_n,

  // Consultas
  input  logic [IDX_W-1:0] query_idx,
  output logic             idx_is_valid,

  // Control desde la FSM
  input  logic             reveal_pulse,
  input  logic [IDX_W-1:0] idx_reveal,
  input  logic             pair_mark_pulse,

  // Estado hacia la FSM/otros
  output logic             match_equal,
  output logic             all_paired,
  output logic [N_CARDS-1:0] matched_mask,
  output logic [N_CARDS-1:0] revealed_mask,
  output logic [IDX_W-1:0]   last_rev1,
  output logic               have_rev1,

  // Para render
  output logic [3:0] symbol_id [N_CARDS]
);
  // Símbolos: 8 pares (0..7, 2 veces)
  integer i;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i=0;i<N_CARDS;i++) symbol_id[i] <= i[3:0] % (N_CARDS/2);
    end
  end

  // Máscaras y últimos revelados
  logic [IDX_W-1:0] rev1, rev2;
  logic             have1, have2;
  assign last_rev1 = rev1;
  assign have_rev1 = have1;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      matched_mask  <= '0;
      revealed_mask <= '0;
      rev1 <= '0; have1 <= 1'b0;
      rev2 <= '0; have2 <= 1'b0;
    end else begin
      // revelar
      if (reveal_pulse) begin
        if (!revealed_mask[idx_reveal] && !matched_mask[idx_reveal]) begin
          revealed_mask[idx_reveal] <= 1'b1;
          if (!have1) begin rev1<=idx_reveal; have1<=1'b1; end
          else if (!have2) begin rev2<=idx_reveal; have2<=1'b1; end
        end
      end

      // marcar pareja definitiva
      if (pair_mark_pulse && have1 && have2) begin
        if (symbol_id[rev1] == symbol_id[rev2]) begin
          matched_mask[rev1]  <= 1'b1;
          matched_mask[rev2]  <= 1'b1;
        end
        // ocultar ambas (FSM decide cuándo hacer pair_mark_pulse tras mostrar)
        revealed_mask[rev1] <= 1'b0;
        revealed_mask[rev2] <= 1'b0;
        have1 <= 1'b0; have2 <= 1'b0;
      end
    end
  end

  // all_paired
  always_comb begin
    all_paired = 1'b1;
    for (int k=0;k<N_CARDS;k++) if (!matched_mask[k]) all_paired=1'b0;
  end

  // match_equal cuando hay 2 reveladas
  always_comb begin
    match_equal = 1'b0;
    if (have1 && have2) begin
      match_equal = (symbol_id[rev1] == symbol_id[rev2]);
    end
  end

  // Consulta de validez
  assign idx_is_valid = (!matched_mask[query_idx] && !revealed_mask[query_idx]);
endmodule

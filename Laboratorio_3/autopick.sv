// =============================================================
// autopick: elige índice válido cuando expira el tiempo (timer15_done)
// Regla: escoge al azar entre posiciones no emparejadas y no reveladas.
// Si exclude_valid=1, evita devolver exclude_idx (útil para NAV2).
// =============================================================
module autopick #(
  parameter int N_CARDS = 16,
  parameter int IDX_W   = $clog2(N_CARDS)
)(
  input  logic             clk,
  input  logic             rst_n,
  input  logic             timer15_done,           // flanco -> genera auto_valid
  input  logic [N_CARDS-1:0] matched_mask,         // 1 = ya emparejada
  input  logic [N_CARDS-1:0] revealed_mask,        // 1 = actualmente revelada
  input  logic             exclude_valid,
  input  logic [IDX_W-1:0] exclude_idx,
  output logic             auto_valid,             // pulso 1 ciclo
  output logic [IDX_W-1:0] auto_idx
);
  // detectar flanco de timer15_done
  logic t15_q;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) t15_q <= 1'b0;
    else        t15_q <= timer15_done;
  end
  wire t15_rise = (timer15_done && !t15_q);

  // LFSR simple para índice
  logic [15:0] rnd;
  lfsr16 prng(.clk(clk), .rst_n(rst_n), .enable(1'b1), .seed(16'hACE1), .rnd(rnd));

  // Selección: intenta hasta N_CARDS veces
  function automatic [IDX_W-1:0] pick(input [15:0] r);
    pick = r[IDX_W-1:0];
  endfunction

  integer k;
  logic [IDX_W-1:0] candidate;
  logic found;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      auto_valid <= 1'b0;
      auto_idx   <= '0;
    end else begin
      auto_valid <= 1'b0;
      if (t15_rise) begin
        found = 1'b0;
        for (k=0; k<N_CARDS; k=k+1) begin
          candidate = pick(rnd + k);
          if (!matched_mask[candidate] && !revealed_mask[candidate] &&
              !(exclude_valid && (candidate==exclude_idx))) begin
            auto_idx   <= candidate;
            auto_valid <= 1'b1;
            found      <= 1'b1;
            break;
          end
        end
        // Si no encontró, devuelve 0 con auto_valid=1 como último recurso
        if (!found) begin
          auto_idx   <= '0;
          auto_valid <= 1'b1;
        end
      end
    end
  end
endmodule

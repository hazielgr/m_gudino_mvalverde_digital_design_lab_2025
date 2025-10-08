// =============================================================
// debounce_1shot: filtro de rebote + pulso 1-ciclo
// - usa tick_1khz para integrar (≈10 ms por defecto)
// =============================================================
module debounce_1shot #(
  parameter int HOLD_MS = 10
)(
  input  logic clk,
  input  logic rst_n,
  input  logic tick_1khz,
  input  logic btn_in,      // asíncrono/mecánico
  output logic pulse        // pulso 1-ciclo limpio
);
  // sincronizador doble
  logic s1, s2;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin s1<=1'b0; s2<=1'b0; end
    else begin s1<=btn_in; s2<=s1; end
  end

  // integrador a 1 kHz
  logic [$clog2(HOLD_MS+1)-1:0] cnt;
  logic stable;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin cnt<='0; stable<=1'b0; end
    else if (tick_1khz) begin
      if (s2) begin
        if (cnt < HOLD_MS) cnt <= cnt + 1'b1;
        if (cnt == HOLD_MS-1) stable <= 1'b1;
      end else begin
        cnt <= '0; stable <= 1'b0;
      end
    end
  end

  // flanco de subida -> pulso 1-ciclo
  logic stable_q;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin stable_q<=1'b0; pulse<=1'b0; end
    else begin
      pulse    <= (stable && !stable_q);
      stable_q <= stable;
    end
  end
endmodule

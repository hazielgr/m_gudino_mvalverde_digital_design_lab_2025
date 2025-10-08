// =============================================================
// timer_down: temporizador descendente con start/reload/stop
// - Cuenta en "ticks" externos (e.g., 1 Hz o 1 kHz)
// =============================================================
module timer_down #(
  parameter int WIDTH = 24
)(
  input  logic clk,
  input  logic rst_n,
  input  logic tick,            // pulso base (1 Hz recomendado)
  input  logic start,           // habilita el conteo (si estaba parado)
  input  logic reload,          // recarga al valor preload y continúa (si estaba en start)
  input  logic stop,            // deshabilita el conteo
  input  logic [WIDTH-1:0] preload, // valor de recarga
  output logic done,            // pulso cuando llega a cero
  output logic [WIDTH-1:0] value // valor actual
);
  logic running;

  // control de running
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) running <= 1'b0;
    else begin
      if (stop)       running <= 1'b0;
      else if (start) running <= 1'b1;
    end
  end

  // contador
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      value <= '0; done <= 1'b0;
    end else begin
      done <= 1'b0;
      if (reload) value <= preload;
      else if (running && tick) begin
        if (value == 0) begin
          done  <= 1'b1; // pulso cuando está en cero
        end else begin
          value <= value - 1'b1;
        end
      end
    end
  end
endmodule

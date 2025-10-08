// =============================================================
// mem_pkg: Parámetros compartidos para el juego Memoria
// =============================================================
package mem_pkg;
  parameter int CLK_HZ   = 50_000_000;      // ajusta según tu placa
  parameter int N_CARDS  = 16;              // 4x4
  parameter int IDX_W    = $clog2(N_CARDS);
  parameter int GRID_W   = 4;
  parameter int GRID_H   = 4;
  parameter int H_PIX    = 640;
  parameter int V_PIX    = 480;
  parameter int TILE_W   = H_PIX/GRID_W;    // 160
  parameter int TILE_H   = V_PIX/GRID_H;    // 120
endpackage

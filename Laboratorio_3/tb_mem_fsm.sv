`timescale 1ns/1ps

module tb_mem_fsm;

  // ------------------------------------------------------------
  // Parámetros
  // ------------------------------------------------------------
  localparam integer N_CARDS = 16;
  localparam integer IDX_W   = $clog2(N_CARDS);

  // Enumeración de estados (solo para impresión legible)
  // NOTA: Deben coincidir con mem_fsm.sv
  localparam [3:0]
    S_INIT       = 4'd0,
    S_TURN_START = 4'd1,
    S_NAV1       = 4'd2,
    S_REV1       = 4'd3,
    S_NAV2       = 4'd4,
    S_REV2       = 4'd5,
    S_EVAL       = 4'd6,
    S_SHOWMISS   = 4'd7,
    S_AUTO1      = 4'd8,
    S_AUTO2      = 4'd9,
    S_GAMEOVER   = 4'd10;

  // ------------------------------------------------------------
  // Reloj / Reset
  // ------------------------------------------------------------
  reg clk; reg rst_n;
  initial begin clk = 1'b0; forever #5 clk = ~clk; end // 100 MHz
  initial begin rst_n = 1'b0; repeat (5) @(posedge clk); rst_n = 1'b1; end

  // ------------------------------------------------------------
  // Señales entre módulos
  // ------------------------------------------------------------
  // TB->FSM
  reg                 pick_valid;
  reg  [IDX_W-1:0]    pick_idx;

  // Timer grande (simulado por TB)
  reg                 timer15_done;
  wire                timer15_start, timer15_reload, timer15_stop;

  // Mini-timer (simulado por TB)
  reg                 mini_done;
  wire                mini_start;

  // Board/view
  wire                reveal_pulse;
  wire [IDX_W-1:0]    idx_reveal;
  wire                pair_mark_pulse;

  // Auto-pick
  wire                auto_valid;
  wire [IDX_W-1:0]    auto_idx;

  // Desde board hacia FSM
  reg  [IDX_W-1:0]    query_idx;
  wire                idx_is_valid;
  wire                match_equal;
  wire                all_paired;

  // Estado y marcadores
  wire [3:0]          fsm_state;
  wire [1:0]          cur_player, winner;
  wire                score_inc_pulse, gameover;

  // ------------------------------------------------------------
  // Instancias
  // ------------------------------------------------------------
  // Tablero
  wire [N_CARDS-1:0]  matched_mask, revealed_mask;
  wire [IDX_W-1:0]    last_rev1;
  wire                have_rev1;
  // Nota: arreglo de símbolos SV; ModelSim 20.1 suele aceptarlo
  wire [3:0]          symbol_id [N_CARDS-1:0];

  reg                 shuffle_pulse;
  reg  [15:0]         shuffle_seed;

  mem_board #(.N_CARDS(N_CARDS), .IDX_W(IDX_W), .SYM_W(4)) u_board (
    .clk(clk), .rst_n(rst_n),
    .query_idx(query_idx),
    .idx_is_valid(idx_is_valid),
    .reveal_pulse(reveal_pulse),
    .idx_reveal(idx_reveal),
    .pair_mark_pulse(pair_mark_pulse),
    .shuffle_pulse(shuffle_pulse),
    .shuffle_seed(shuffle_seed),
    .matched_mask(matched_mask),
    .revealed_mask(revealed_mask),
    .last_rev1(last_rev1),
    .have_rev1(have_rev1),
    .symbol_id(symbol_id),
    .match_equal(match_equal),
    .all_paired(all_paired)
  );

  // Auto-pick
  autopick #(.N_CARDS(N_CARDS), .IDX_W(IDX_W)) u_autopick (
    .clk(clk), .rst_n(rst_n),
    .timer15_done(timer15_done),
    .matched_mask(matched_mask),
    .revealed_mask(revealed_mask),
    .exclude_valid(have_rev1),
    .exclude_idx(last_rev1),
    .auto_valid(auto_valid),
    .auto_idx(auto_idx)
  );

  // FSM principal
  mem_fsm #(.N_CARDS(N_CARDS), .IDX_W(IDX_W)) u_fsm (
    .clk(clk), .rst_n(rst_n),
    .pick_valid(pick_valid), .pick_idx(pick_idx),
    .idx_is_valid(idx_is_valid), .match_equal(match_equal), .all_paired(all_paired),
    .auto_valid(auto_valid), .auto_idx(auto_idx),
    .timer15_done(timer15_done), .timer15_start(timer15_start),
    .timer15_reload(timer15_reload), .timer15_stop(timer15_stop),
    .mini_done(mini_done), .mini_start(mini_start),
    .reveal_pulse(reveal_pulse), .idx_reveal(idx_reveal), .pair_mark_pulse(pair_mark_pulse),
    .cur_player(cur_player), .score_inc_pulse(score_inc_pulse),
    .gameover(gameover), .winner(winner), .fsm_state(fsm_state)
  );

  // Scoreboard
  wire [3:0] sb_score_j1, sb_score_j2;
  scoreboard u_score (
    .clk(clk), .rst_n(rst_n),
    .cur_player(cur_player),
    .score_inc_pulse(score_inc_pulse),
    .score_j1(sb_score_j1),
    .score_j2(sb_score_j2)
  );

  // ------------------------------------------------------------
  // Mini-timer compatible (pulso de mini_done 1 ciclo tras 3 ticks)
  // ------------------------------------------------------------
  reg [2:0] mini_cnt;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mini_cnt  <= 3'd0;
      mini_done <= 1'b0;
    end else begin
      if (mini_start) begin
        mini_cnt  <= 3'd3; // espera 3 ciclos
        mini_done <= 1'b0;
      end else if (mini_cnt != 3'd0) begin
        mini_cnt <= mini_cnt - 3'd1;
        if (mini_cnt == 3'd1)
          mini_done <= 1'b1; // pulso 1 ciclo
        else
          mini_done <= 1'b0;
      end else begin
        mini_done <= 1'b0;
      end
    end
  end

  // ------------------------------------------------------------
  // Utilidades TB
  // ------------------------------------------------------------
  // Impresión legible de estado (sin strings)
  task automatic print_state(input [3:0] s);
    begin
      case (s)
        S_INIT:       $display("[%0t] STATE: S_INIT", $time);
        S_TURN_START: $display("[%0t] STATE: S_TURN_START", $time);
        S_NAV1:       $display("[%0t] STATE: S_NAV1", $time);
        S_REV1:       $display("[%0t] STATE: S_REV1", $time);
        S_NAV2:       $display("[%0t] STATE: S_NAV2", $time);
        S_REV2:       $display("[%0t] STATE: S_REV2", $time);
        S_EVAL:       $display("[%0t] STATE: S_EVAL", $time);
        S_SHOWMISS:   $display("[%0t] STATE: S_SHOWMISS", $time);
        S_AUTO1:      $display("[%0t] STATE: S_AUTO1", $time);
        S_AUTO2:      $display("[%0t] STATE: S_AUTO2", $time);
        S_GAMEOVER:   $display("[%0t] STATE: S_GAMEOVER", $time);
        default:      $display("[%0t] STATE: UNKNOWN (%0d)", $time, s);
      endcase
    end
  endtask

  // Seguimiento de cambios de estado
  reg [3:0] prev_state;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      prev_state <= 4'hF;
    end else if (fsm_state != prev_state) begin
      print_state(fsm_state);
      prev_state <= fsm_state;
    end
  end

  // Seguimiento de eventos del tablero
  integer rev_count;
  integer last_rev_a, last_rev_b;
  always @(posedge clk) begin
    if (reveal_pulse) begin
      rev_count = rev_count + 1;
      if (last_rev_a < 0) last_rev_a = idx_reveal;
      else                last_rev_b = idx_reveal;
      $display("[%0t] REVEAL idx=%0d  (rev_count=%0d)", $time, idx_reveal, rev_count);
    end
    if (pair_mark_pulse) begin
      $display("[%0t] PAIR_MARK  match_equal=%0d", $time, match_equal);
      last_rev_a = -1; last_rev_b = -1;
    end
  end

task automatic user_pick(input integer idx);
  begin
    query_idx  = idx[IDX_W-1:0];
    pick_idx   = idx[IDX_W-1:0];
    pick_valid = 1'b1;
    repeat (2) @(posedge clk); // <-- antes era 1, ahora 2 ciclos
    pick_valid = 1'b0;
    query_idx  = {IDX_W{1'b0}};
  end
endtask


  // Forzar timeout (1 ciclo alto)
  task automatic force_timeout_15s;
    begin
      timer15_done = 1'b1;
      @(posedge clk);
      timer15_done = 1'b0;
    end
  endtask

  // Buscar dos índices con mismo símbolo (no emparejados)
  task automatic find_pair(output integer i, output integer j);
    integer s, k;
    integer first;
    begin
      i = -1; j = -1;
      for (s = 0; s < 8; s = s + 1) begin
        first = -1;
        for (k = 0; k < N_CARDS; k = k + 1) begin
          if (!matched_mask[k] && (symbol_id[k] == s[3:0])) begin
            if (first == -1) first = k;
            else begin
              i = first; j = k;
              disable find_pair;
            end
          end
        end
      end
    end
  endtask

  function integer find_mismatch_idx(input integer avoid_sym);
    integer k;
    begin
      find_mismatch_idx = -1; // valor por defecto
      for (k = 0; k < N_CARDS; k = k + 1) begin
        if (!matched_mask[k] && !revealed_mask[k] && (symbol_id[k] != avoid_sym[3:0])) begin
          find_mismatch_idx = k;
          return find_mismatch_idx; // devuelve al encontrar uno válido
        end
      end
      return find_mismatch_idx; // asegura retorno siempre
    end
  endfunction

  // ------------------------------------------------------------
  // Estímulos principales
  // ------------------------------------------------------------
  initial begin
    // Iniciales
    pick_valid   = 1'b0;
    pick_idx     = {IDX_W{1'b0}};
    query_idx    = {IDX_W{1'b0}};
    shuffle_pulse= 1'b0;
    shuffle_seed = 16'hBEEF;
    timer15_done = 1'b0;
    mini_done    = 1'b0;
    rev_count    = 0;
    last_rev_a   = -1;
    last_rev_b   = -1;

    @(posedge rst_n);
    $display("============= INICIO AUTOCHECK (Quartus-friendly) =============");

    // Esperar que la FSM alcance NAV1 (tras init/turn_start)
    wait (fsm_state == S_NAV1);

    // --- A) Match manual ---
    begin
      integer a,b;
      find_pair(a,b);
      $display("--- A: Match manual con indices (%0d,%0d)  sym=%0d ---", a,b, symbol_id[a]);
      user_pick(a);
      wait (fsm_state == S_NAV2);
      user_pick(b);
      wait (fsm_state == S_EVAL);
      wait (pair_mark_pulse);
      wait (fsm_state == S_TURN_START);
    end

    // --- B) Mismatch manual (cae a SHOWMISS y cambia jugador) ---
    begin
      integer a,b, mis;
      find_pair(a,b); // toma un par, pero usaremos mismatch para 2do pick
      $display("--- B: Mismatch manual: pick1=%0d (sym=%0d) ---", a, symbol_id[a]);
      user_pick(a);
      wait (fsm_state == S_NAV2);
      mis = find_mismatch_idx(symbol_id[a]);
      $display("--- B: Mismatch manual: pick2=%0d (sym=%0d) ---", mis, symbol_id[mis]);
      user_pick(mis);
      wait (fsm_state == S_EVAL);
      wait (fsm_state == S_SHOWMISS);
      // mini_done llegará automáticamente por el mini-timer TB
      wait (fsm_state == S_TURN_START);
    end

    // --- C) Timeout en NAV1 -> AUTO1 ---
    begin
      $display("--- C: Timeout NAV1 -> AUTO1 ---");
      wait (fsm_state == S_NAV1);
      force_timeout_15s();
      // tras AUTO1, FSM debería continuar a NAV2
      wait (fsm_state == S_NAV2);
    end

    // --- D) Timeout en NAV2 -> AUTO2 ---
    begin
      $display("--- D: Timeout NAV2 -> AUTO2 ---");
      wait (fsm_state == S_NAV2);
      force_timeout_15s();
      wait (fsm_state == S_EVAL);
      @(posedge clk);
      if (pair_mark_pulse) $display("--- D: AUTO2 produjo un par ---");
      else                 $display("--- D: AUTO2 produjo mismatch ---");
      wait (fsm_state == S_TURN_START || fsm_state == S_GAMEOVER);
    end

    // --- E) Completar pares restantes hasta GAMEOVER ---
    begin
      integer i,j;
      $display("--- E: Completar pares restantes hasta GAMEOVER ---");
      // bucle hasta que el board reporte all_paired=1 y la FSM llegue a GAMEOVER
      while (!all_paired) begin
        find_pair(i,j);
        if (i == -1 || j == -1) begin
          wait (fsm_state == S_TURN_START);
        end else begin
          user_pick(i);
          wait (fsm_state == S_NAV2);
          user_pick(j);
          wait (fsm_state == S_EVAL);
          wait (pair_mark_pulse);
        end
      end
      wait (fsm_state == S_GAMEOVER);
    end

    // Reporte final
    $display("===============================================================");
    $display(" AUTOCHECK COMPLETADO ");
    $display(" Score J1=%0d  J2=%0d  Winner=%0d  GameOver=%0d",
             sb_score_j1, sb_score_j2, winner, gameover);
    $display("===============================================================");
    $finish;
  end

endmodule
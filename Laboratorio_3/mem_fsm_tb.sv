// =============================================================
// TESTBENCH: mem_fsm_tb  (corregido timing match_equal)
// =============================================================
`timescale 1ns/1ps
module mem_fsm_tb;
    localparam int N_CARDS = 16;
    localparam int IDX_W   = $clog2(N_CARDS);

    // ===== Estados (idénticos a los del DUT) =====
    localparam logic [3:0]
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

    // Reloj y reset
    logic clk = 0; always #5 clk = ~clk; // 100 MHz sim
    logic rst_n = 0;

    // Señales hacia la FSM
    logic                 pick_valid;
    logic [IDX_W-1:0]     pick_idx;

    logic                 idx_is_valid;
    logic                 match_equal;
    logic                 all_paired;

    logic                 auto_valid;
    logic [IDX_W-1:0]     auto_idx;

    logic                 timer15_done;
    logic                 timer15_start, timer15_reload, timer15_stop;

    logic                 mini_done;
    logic                 mini_start;

    logic                 reveal_pulse;
    logic [IDX_W-1:0]     idx_reveal;
    logic                 pair_mark_pulse;

    logic [1:0]           cur_player;
    logic                 score_inc_pulse;
    logic                 gameover;
    logic [1:0]           winner;
    logic [3:0]           fsm_state;

    // DUT
    mem_fsm #(.N_CARDS(N_CARDS)) dut (
        .clk, .rst_n,
        .pick_valid, .pick_idx,
        .idx_is_valid, .match_equal, .all_paired,
        .auto_valid, .auto_idx,
        .timer15_done, .timer15_start, .timer15_reload, .timer15_stop,
        .mini_done, .mini_start,
        .reveal_pulse, .idx_reveal, .pair_mark_pulse,
        .cur_player, .score_inc_pulse, .gameover, .winner,
        .fsm_state
    );

    // ---------------------------------------------------------
    // MODELO SIMPLE (lógica necesaria)
    // ---------------------------------------------------------
    int deck   [N_CARDS];
    bit paired [N_CARDS];
    int sb_score_j1, sb_score_j2;

    // Inicializa mazo determinista
    task init_deck;
        int i;
        int temp [16];
        begin
            temp[0]=0;  temp[1]=1;  temp[2]=2;  temp[3]=3;
            temp[4]=4;  temp[5]=5;  temp[6]=6;  temp[7]=7;
            temp[8]=0;  temp[9]=1;  temp[10]=2; temp[11]=3;
            temp[12]=4; temp[13]=5; temp[14]=6; temp[15]=7;
            for (i=0;i<N_CARDS;i++) begin
                deck[i]   = temp[i];
                paired[i] = 0;
            end
            sb_score_j1 = 0; sb_score_j2 = 0;
        end
    endtask

    // Validez de índice: no emparejada
    function bit is_valid_idx (int idx);
        return (idx>=0 && idx<N_CARDS && !paired[idx]);
    endfunction
    always_comb idx_is_valid = is_valid_idx(pick_idx);

    // Auto-pick simple
    task automatic next_auto_idx(input int forbid_idx=-1);
        int k; auto_valid = 0; auto_idx = '0;
        for (k=0;k<N_CARDS;k++) begin
            if (is_valid_idx(k) && k!=forbid_idx) begin
                auto_idx   = k[IDX_W-1:0];
                auto_valid = 1;
                break;
            end
        end
    endtask

    // Temporizador 15s simulado (lo maneja el test)
    initial begin
        timer15_done = 0;
        forever begin
            @(posedge clk);
            if (timer15_stop)                         timer15_done <= 0;
            else if (timer15_reload || timer15_start) timer15_done <= 0;
        end
    end

    // Mini temporizador (SHOWMISS): 5 ciclos tras mini_start
    initial begin
        mini_done = 0;
        forever begin
            @(posedge clk);
            if (mini_start) begin
                repeat (5) @(posedge clk);
                mini_done <= 1; @(posedge clk); mini_done <= 0;
            end
        end
    end

    // Utilidades
    task user_pick(input int idx);
        pick_idx   = idx[IDX_W-1:0];
        pick_valid = 1; @(posedge clk); pick_valid = 0;
    endtask

    // Rastreo de dos últimas revelaciones (secuencial)
    int last_rev1=-1, last_rev2=-1;
    always @(posedge clk) begin
        if (reveal_pulse) begin
            if (last_rev1==-1) last_rev1 <= idx_reveal; else last_rev2 <= idx_reveal;
        end
        if (pair_mark_pulse && last_rev1!=-1 && last_rev2!=-1) begin
            paired[last_rev1] <= 1; paired[last_rev2] <= 1;
            if (cur_player==2'b00) sb_score_j1++; else sb_score_j2++;
        end
        if (fsm_state==S_TURN_START) begin
            last_rev1 <= -1; last_rev2 <= -1;
        end
    end

    // match_equal debe estar disponible COMBINACIONAL en S_EVAL
    always_comb begin
        if (fsm_state==S_EVAL && last_rev1!=-1 && last_rev2!=-1)
            match_equal = (deck[last_rev1] == deck[last_rev2]);
        else
            match_equal = 1'b0;
    end

    // Conteo de emparejadas para all_paired (combinacional)
    int count;
    always_comb begin
        count = 0;
        for (int i=0;i<N_CARDS;i++) if (paired[i]) count++;
        all_paired = (count==N_CARDS);
    end

    // ---------------------------------------------------------
    // ESCENARIOS de prueba
    // ---------------------------------------------------------
    initial begin
        pick_valid = 0; pick_idx = '0; auto_valid = 0; auto_idx = '0;
        init_deck();

        repeat (5) @(posedge clk); rst_n = 1; @(posedge clk);

        $display("--- Escenario A: Acierto ---");
        wait (fsm_state==S_NAV1);
        user_pick(0);
        wait (fsm_state==S_NAV2);
        user_pick(8);
        repeat (8) @(posedge clk);
        if (!(sb_score_j1==1 && cur_player==2'b00))
            $display("ERROR: no se anotó punto correctamente");

        $display("--- Escenario B: Falla ---");
        wait (fsm_state==S_NAV1);
        user_pick(1);
        wait (fsm_state==S_NAV2);
        user_pick(2);
        repeat (20) @(posedge clk);
        if (cur_player!=2'b01)
            $display("ERROR: no se cambió de jugador tras fallo");

        $display("--- Escenario C: Timeout NAV1 -> AUTO1 ---");
        wait (fsm_state==S_NAV1);
        timer15_done = 1; @(posedge clk); timer15_done = 0;
        next_auto_idx(-1); @(posedge clk); auto_valid = 1; @(posedge clk); auto_valid = 0;
        repeat (5) @(posedge clk);

        $display("--- Escenario D: Timeout NAV2 -> AUTO2 ---");
        wait (fsm_state==S_NAV2);
        timer15_done = 1; @(posedge clk); timer15_done = 0;
        next_auto_idx(last_rev1); @(posedge clk); auto_valid = 1; @(posedge clk); auto_valid = 0;
        repeat (10) @(posedge clk);

        $display("==============================");
        $display(" Autochequeo completado ");
        $display(" Scoreboard J1=%0d J2=%0d ", sb_score_j1, sb_score_j2);
        $display("==============================");
        $finish;
    end

endmodule

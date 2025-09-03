module top_lab1_ej3 (
    input  logic        CLOCK_50,      
    input  logic        SW_RESET,      // 1 = reset; 0 = normal
    input  logic        KEY_UP_N,      // botón subir contador 
    input  logic        KEY_LOAD_N,    // botón cargar 
    input  logic [5:0]  SW_PRESET,     // valor inicial a cargar
    output logic [6:0]  HEX1,          // decenas
    output logic [6:0]  HEX0           // unidades
);

    // -------------------------
    // Reloj y reset
    // -------------------------
    wire  clk;               // net para usar con asignación continua
    assign clk = CLOCK_50;   // alias local del clock

    wire  arst_n;            // reset asíncrono activo en 0
    assign arst_n = ~SW_RESET;

    wire  rst_sync_n;        // reset síncrono interno (aquí lo igualamos)
    assign rst_sync_n = arst_n;

    // -------------------------
    // Entradas de botones (nivel)
    // OJO: usar nets + assign, no inicializar variables con señales
    // -------------------------
    wire up_level_raw;                    // nivel "subir" sin filtrar
    wire load_level_raw;                  // nivel "cargar" sin filtrar
    assign up_level_raw   = ~KEY_UP_N;    // pasan a activo-en-alto
    assign load_level_raw = ~KEY_LOAD_N;

    // -------------------------
    // Antirrebote (debounce) de nivel
    // -------------------------
    logic up_level_clean, load_level_clean;
    btn_debouncer #(.CYCLES(250_000)) u_db_up (
        .clk(clk),
        .rst_n(rst_sync_n),
        .noisy_in(up_level_raw),
        .clean_out(up_level_clean)
    );

    btn_debouncer #(.CYCLES(250_000)) u_db_load (
        .clk(clk),
        .rst_n(rst_sync_n),
        .noisy_in(load_level_raw),
        .clean_out(load_level_clean)
    );

    // -------------------------
    // Generación de pulso 1 ciclo a partir del nivel limpio
    // -------------------------
    logic up_pulse, load_pulse;
    one_pulse u_pulse_up (
        .clk(clk),
        .rst_n(rst_sync_n),
        .level_in(up_level_clean),
        .pulse_out(up_pulse)
    );

    one_pulse u_pulse_load (
        .clk(clk),
        .rst_n(rst_sync_n),
        .level_in(load_level_clean),
        .pulse_out(load_pulse)
    );

    // -------------------------
    // Contador de 6 bits con carga por pulso
    // -------------------------
    logic [5:0] q;
    counter #(.N(6)) u_cnt (
        .clk(clk),
        .arst_n(arst_n),          // reset asíncrono
        .enable(up_pulse),        // un pulso = +1
        .load(load_pulse),        // un pulso = cargar SW_PRESET
        .load_value(SW_PRESET),
        .q(q)
    );

    // -------------------------
    // Conversión a dos dígitos decimales (0–63)
    // -------------------------
    logic [3:0] tens, ones;
    bin_to_dec2digits u_b2d (
        .bin(q),
        .tens(tens),
        .ones(ones)
    );

    // -------------------------
    // Decodificadores a 7 segmentos
    // -------------------------
    seven_seg_decoder_dec u_dec0 (
        .d(ones),
        .seg(HEX0)
    );

    seven_seg_decoder_dec u_dec1 (
        .d(tens),
        .seg(HEX1)
    );

endmodule

// SW[3:0]  -> DATA_BUS (cargar A, B y SHAMT)
// SW[7:4]  -> OP[3:0]  (0000 ADD,0001 SUB,0010 MUL,0011 DIV,0100 MOD,0101 AND,0110 OR,0111 XOR,1000 SHL,1001 SHR)
// SW[9]    -> RESET (0 = limpia registros A, B y SHAMT; 1 = normal)
// KEY0     -> LOAD A
// KEY1     -> LOAD B
// KEY2     -> LOAD SHAMT (sólo si OP=1000/1001)
// HEX*: solo resultado en decimal (2 dígitos normal / 3 dígitos MUL)
// LED[3:0] -> {N,Z,C,V}

module top_lab2 #(
  parameter int N = 4
)(
  input  logic        CLOCK_50,
  input  logic [9:0]  SW,
  input  logic [3:0]  KEY,         // activos en bajo
  output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
  output logic [3:0]  LED
);
  // ---------- UI: switches ----------
  logic [3:0] DATA_BUS;
  logic [3:0] OP;
  logic       RESET_N;
  assign DATA_BUS = SW[3:0];
  assign OP       = SW[7:4];
  assign RESET_N  = SW[9];   // Reset manual: 1=normal, 0=reset

  // ---------- Debounce + one-pulse ----------
  logic ldA_lvl, ldB_lvl, ldS_lvl;
  logic ldA_p,   ldB_p,   ldS_p;
  btn_debouncer #(.CNT(20)) DB0 (.clk(CLOCK_50), .btn_n(KEY[0]), .btn_clean(ldA_lvl));
  btn_debouncer #(.CNT(20)) DB1 (.clk(CLOCK_50), .btn_n(KEY[1]), .btn_clean(ldB_lvl));
  btn_debouncer #(.CNT(20)) DB2 (.clk(CLOCK_50), .btn_n(KEY[2]), .btn_clean(ldS_lvl));
  one_pulse OP0 (.clk(CLOCK_50), .level_in(ldA_lvl), .pulse_out(ldA_p));
  one_pulse OP1 (.clk(CLOCK_50), .level_in(ldB_lvl), .pulse_out(ldB_p));
  one_pulse OP2 (.clk(CLOCK_50), .level_in(ldS_lvl), .pulse_out(ldS_p));

  // ---------- Registros A, B, SHAMT ----------
  logic [N-1:0] A_reg, B_reg;
  logic [$clog2(N)-1:0] SHAMT_reg; // N=4 -> 2 bits

  always_ff @(posedge CLOCK_50) begin
    if (!RESET_N) begin
      A_reg     <= '0;
      B_reg     <= '0;
      SHAMT_reg <= '0;
    end else begin
      if (ldA_p) A_reg     <= DATA_BUS[N-1:0];
      if (ldB_p) B_reg     <= DATA_BUS[N-1:0];
      if (ldS_p) SHAMT_reg <= DATA_BUS[$clog2(N)-1:0];
    end
  end

  // ---------- ALU ----------
  logic [N-1:0]   Rn;
  logic [2*N-1:0] Rw;
  logic Nf, Zf, Cf, Vf;
  alu #(.N(N)) U_ALU (
    .A(A_reg), .B(B_reg), .OP(OP), .SHAMT(SHAMT_reg),
    .Rout(Rn), .Rout_w(Rw),
    .Nflag(Nf), .Zflag(Zf), .Cflag(Cf), .Vflag(Vf)
  );

  // ---------- Flags -> LEDs ----------
  assign LED = {Nf, Zf, Cf, Vf};

  // ---------- BIN -> BCD -> 7-seg ----------
  logic is_mul;
  assign is_mul = (OP == 4'b0010);

  logic [11:0] bcd3;  // 3 dígitos (centenas, decenas, unidades)
  logic [7:0]  bcd2;  // 2 dígitos (decenas, unidades)

  bin_to_bcd #(.WIDTH(8), .DIGITS(3)) B2D3 (.bin(Rw[7:0]), .bcd(bcd3));
  bin_to_bcd #(.WIDTH(4), .DIGITS(2)) B2D2 (.bin(Rn[3:0]), .bcd(bcd2));

  wire [3:0] d0 = is_mul ? bcd3[3:0]  : bcd2[3:0];   // unidades
  wire [3:0] d1 = is_mul ? bcd3[7:4]  : bcd2[7:4];   // decenas
  wire [3:0] d2 = is_mul ? bcd3[11:8] : 4'h0;        // centenas (solo MUL)

  hex7seg H0 (.hex(d0), .seg(HEX0));
  hex7seg H1 (.hex(d1), .seg(HEX1));
  hex7seg H2 (.hex(d2), .seg(HEX2));
  assign HEX3 = 7'b1111111;
  assign HEX4 = 7'b1111111;
  assign HEX5 = 7'b1111111;

endmodule

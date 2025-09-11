`timescale 1ns/1ps

module ALU_TB;
  // ------- Parámetros -------
  localparam int N = 4;
  localparam int W = 2*N;
  localparam int MASK = (1<<N)-1;

  // ------- DUT -------
  logic [N-1:0] A, B;
  logic [3:0]   OP;
  logic [$clog2(N)-1:0] SHAMT;
  logic [N-1:0]   Rout;
  logic [W-1:0]   Rout_w;
  logic Nf, Zf, Cf, Vf;

  alu #(.N(N)) dut (
    .A(A), .B(B), .OP(OP), .SHAMT(SHAMT),
    .Rout(Rout), .Rout_w(Rout_w),
    .Nflag(Nf), .Zflag(Zf), .Cflag(Cf), .Vflag(Vf)
  );

  // ------- Helpers matemáticos / flags -------
  function automatic logic add_carry_out(input int unsigned a, b);
    add_carry_out = (((a + b) >> N) & 1);
  endfunction

  function automatic logic sub_borrow(input int unsigned a, b);
    int unsigned sum;
    logic cout;
    sum = a + ((~b) & MASK) + 1;
    cout = (sum >> N) & 1;
    sub_borrow = ~cout;
  endfunction

  function automatic logic of_add(input logic msbA, msbB, msbR);
    of_add = ((msbA==msbB) && (msbR!=msbA));
  endfunction

  function automatic logic of_sub(input logic msbA, msbB, msbR);
    of_sub = ((msbA!=msbB) && (msbR!=msbA));
  endfunction

  function automatic logic shift_carry_left(input logic [N-1:0] x, input int unsigned k);
    logic c;
    if (k==0) return 1'b0;
    if (k > N) k = N;
    c = x[N - k];
    return c;
  endfunction

  function automatic logic shift_carry_right(input logic [N-1:0] x, input int unsigned k);
    logic c;
    if (k==0) return 1'b0;
    if (k > N) k = N;
    c = x[k-1];
    return c;
  endfunction

  // Nombre de la operación (evita arreglos de strings)
  function automatic string op_name(input [3:0] op);
    case (op)
      4'b0000: op_name = "ADD";
      4'b0001: op_name = "SUB";
      4'b0010: op_name = "MUL";
      4'b0011: op_name = "DIV";
      4'b0100: op_name = "MOD";
      4'b0101: op_name = "AND";
      4'b0110: op_name = "OR";
      4'b0111: op_name = "XOR";
      4'b1000: op_name = "SHL";
      4'b1001: op_name = "SHR";
      default: op_name = "???";
    endcase
  endfunction

  // ------- Pretty print de fila -------
  task automatic print_row(
    input string tag,
    input [3:0]  op_i,
    input int    a_i, b_i, sh_i,
    input int    out_i,
    input [3:0]  nzcv_i,
    input int    exp_out,
    input [3:0]  exp_nzcv,
    output bit   pass_o
  );
    string res;
    pass_o = ((out_i===exp_out) && (nzcv_i===exp_nzcv));
    res = pass_o ? "PASS" : "FAIL";
    $display("%-20s | %3s | A=%2d B=%2d SH=%1d | OUT=%2d | NZCV=%b | EXP=%2d NZCV=%b | %s",
             tag, op_name(op_i), a_i, b_i, sh_i, out_i, nzcv_i, exp_out, exp_nzcv, res);
  endtask

  // ------- Checker por operación -------
  task automatic check(input [3:0] op_i, input int unsigned a_i, b_i, input int unsigned sh_i, input string tag);
    // Declaraciones AL INICIO (ModelSim 2020.1 es estricto)
    int unsigned res_n;
    int unsigned q, r;
    int unsigned prod;
    logic expN, expZ, expC, expV;
    int exp_out_int;
    bit pass_line;

    // Drive DUT
    A = a_i & MASK;
    B = b_i & MASK;
    OP = op_i[3:0];
    SHAMT = sh_i[$clog2(N)-1:0];
    #1;

    // Esperados
    unique case (op_i)
      4'b0000: begin // ADD
        res_n     = (a_i + b_i) & MASK;
        expC      = add_carry_out(a_i, b_i);
        expV      = of_add(A[N-1], B[N-1], res_n[N-1]);
        expN      = res_n[N-1];
        expZ      = (res_n==0);
        exp_out_int = res_n;
      end
      4'b0001: begin // SUB (C=borrow)
        res_n     = (a_i - b_i) & MASK;
        expC      = sub_borrow(a_i, b_i);
        expV      = of_sub(A[N-1], B[N-1], res_n[N-1]);
        expN      = res_n[N-1];
        expZ      = (res_n==0);
        exp_out_int = res_n;
      end
      4'b0010: begin // MUL (usar producto de 8 bits)
        prod      = (a_i * b_i) & ((1<<W)-1);
        res_n     = prod & MASK;
        expN      = (prod >> (W-1)) & 1; // MSB del ancho W
        expZ      = (prod==0);
        expC      = 1'b0;
        expV      = 1'b0;
        exp_out_int = res_n; // mostramos la parte baja en OUT (Rout)
      end
      4'b0011: begin // DIV
        q         = (b_i==0) ? 0 : (a_i / b_i);
        res_n     = q & MASK;
        expN      = res_n[N-1];
        expZ      = (res_n==0);
        expC      = 1'b0;
        expV      = 1'b0;
        exp_out_int = res_n;
      end
      4'b0100: begin // MOD
        r         = (b_i==0) ? (a_i & MASK) : (a_i % b_i);
        res_n     = r & MASK;
        expN      = res_n[N-1];
        expZ      = (res_n==0);
        expC      = 1'b0;
        expV      = 1'b0;
        exp_out_int = res_n;
      end
      4'b0101, // AND
      4'b0110, // OR
      4'b0111: begin // XOR
        int unsigned y;
        if (op_i==4'b0101) y = (a_i & b_i);
        else if (op_i==4'b0110) y = (a_i | b_i);
        else y = (a_i ^ b_i);
        res_n     = y & MASK;
        expN      = res_n[N-1];
        expZ      = (res_n==0);
        expC      = 1'b0;
        expV      = 1'b0;
        exp_out_int = res_n;
      end
      4'b1000: begin // SHL
        int unsigned k;
        int unsigned y;
        k         = sh_i;
        y         = ((a_i & MASK) << k) & MASK;
        res_n     = y;
        expC      = shift_carry_left (a_i & MASK, k);
        expN      = res_n[N-1];
        expZ      = (res_n==0);
        expV      = 1'b0;
        exp_out_int = res_n;
      end
      4'b1001: begin // SHR
        int unsigned k;
        int unsigned y;
        k         = sh_i;
        y         = ((a_i & MASK) >> k) & MASK;
        res_n     = y;
        expC      = shift_carry_right(a_i & MASK, k);
        expN      = res_n[N-1];
        expZ      = (res_n==0);
        expV      = 1'b0;
        exp_out_int = res_n;
      end
      default: begin
        $fatal(1, "OP no soportado: %b", op_i);
      end
    endcase

    // Imprime fila y marca PASS/FAIL
    print_row(tag, op_i, a_i, b_i, sh_i, Rout, {Nf,Zf,Cf,Vf},
              exp_out_int, {expN,expZ,expC,expV}, pass_line);

    if (op_i==4'b0010) begin
      // Chequeo adicional Rout_w en MUL
      int unsigned prod_local;
      prod_local = (a_i * b_i) & ((1<<W)-1);
      if (Rout_w !== prod_local) begin
        $display("  ! Aviso MUL: Rout_w=%0d esperado=%0d", Rout_w, prod_local);
      end
    end
  endtask

  // ------- Suite de pruebas -------
  initial begin
    int fails;
    fails = 0;

    $display("== TESTBENCH ALU N=%0d ==", N);
    $display("Caso                 | OP  |  A  B SH | OUT | NZCV | EXPECTED | RESULT");
    $display("------------------------------------------------------------------------");

    // ADD
    check(4'b0000, 1, 3, 0, "ADD 1+3");
    check(4'b0000, 9, 9, 0, "ADD 9+9");            // overflow/carry

    // SUB
    check(4'b0001, 7, 3, 0, "SUB 7-3");
    check(4'b0001, 3, 7, 0, "SUB 3-7");            // borrow

    // MUL
    check(4'b0010, 3, 9, 0, "MUL 3*9");
    check(4'b0010, 15,15,0, "MUL 15*15");

    // DIV
    check(4'b0011, 7, 3, 0, "DIV 7/3");
    check(4'b0011, 8, 0, 0, "DIV 8/0");

    // MOD
    check(4'b0100, 7, 3, 0, "MOD 7%3");
    check(4'b0100, 8, 0, 0, "MOD 8%0");

    // Lógicas
    check(4'b0101, 10, 5, 0, "AND 10&5");
    check(4'b0110, 10, 5, 0, "OR 10|5");
    check(4'b0111, 12, 9, 0, "XOR 12^9");

    // Shifts
    check(4'b1000, 10, 0, 1, "SHL 10<<1");
    check(4'b1001, 10, 0, 2, "SHR 10>>2");

    $display("------------------------------------------------------------------------");
    $display("== Fin TB ==");
    $finish;
  end
endmodule

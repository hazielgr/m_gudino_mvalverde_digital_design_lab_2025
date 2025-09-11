

module alu #(
  parameter int N = 4
)(
  input  logic [N-1:0] A, B,
  input  logic [3:0]   OP,     // 0000 ADD,0001 SUB,0010 MUL,0011 DIV,0100 MOD,0101 AND,0110 OR,0111 XOR,1000 SHL,1001 SHR
  input  logic [$clog2(N)-1:0] SHAMT,
  output logic [N-1:0]   Rout,     // salida "normal" (N bits)
  output logic [2*N-1:0] Rout_w,   // salida ancha (MUL)
  output logic Nflag, Zflag, Cflag, Vflag
);
  // Operaciones
  logic [N-1:0] add_s, sub_d, and_y, or_y, xor_y, div_q, mod_r, shft_r;
  logic         add_cout, sub_cout, shft_c;
  logic [2*N-1:0] mul_p;

  n_bit_adder      #(.N(N)) U_ADD (.A(A), .B(B), .Cin(1'b0), .S(add_s), .Cout(add_cout));
  n_bit_subtractor #(.N(N)) U_SUB (.A(A), .B(B),            .D(sub_d), .Cout(sub_cout));
  n_bit_multiplier #(.N(N)) U_MUL (.A(A), .B(B),            .P(mul_p));
  n_bit_and        #(.N(N)) U_AND (.A(A), .B(B),            .Y(and_y));
  n_bit_or         #(.N(N)) U_OR  (.A(A), .B(B),            .Y(or_y));
  n_bit_xor        #(.N(N)) U_XOR (.A(A), .B(B),            .Y(xor_y));
  divisor          #(.N(N)) U_DIV (.A(A), .B(B),            .Q(div_q));
  modulo           #(.N(N)) U_MOD (.A(A), .B(B),            .R(mod_r));

  shifter          #(.N(N)) U_SHF_L (.A(A), .DIR(1'b1), .SHAMT(SHAMT), .R(),        .C_out()); 
  shifter          #(.N(N)) U_SHF   (.A(A), .DIR(OP==4'b1000), .SHAMT(SHAMT), .R(shft_r), .C_out(shft_c));
  // Nota: OP=1000 => DIR=1 (left); OP=1001 => DIR=0 (right)

  // MUX de resultado
  always_comb begin
    unique case (OP)
      4'b0000: begin Rout = add_s;           Rout_w = {{N{1'b0}}, add_s}; end
      4'b0001: begin Rout = sub_d;           Rout_w = {{N{1'b0}}, sub_d}; end
      4'b0010: begin Rout = mul_p[N-1:0];    Rout_w = mul_p;               end
      4'b0011: begin Rout = div_q;           Rout_w = {{N{1'b0}}, div_q}; end
      4'b0100: begin Rout = mod_r;           Rout_w = {{N{1'b0}}, mod_r}; end
      4'b0101: begin Rout = and_y;           Rout_w = {{N{1'b0}}, and_y}; end
      4'b0110: begin Rout = or_y;            Rout_w = {{N{1'b0}}, or_y }; end
      4'b0111: begin Rout = xor_y;           Rout_w = {{N{1'b0}}, xor_y}; end
      4'b1000,
      4'b1001: begin Rout = shft_r;          Rout_w = {{N{1'b0}}, shft_r}; end
      default: begin Rout = '0;              Rout_w = '0;                  end
    endcase
  end

  // Flags
  wire use_wide = (OP == 4'b0010);
  wire msbN     = use_wide ? Rout_w[2*N-1] : Rout[N-1];
  wire isZero   = use_wide ? (Rout_w == '0) : (Rout == '0);

  always_comb begin
    Nflag = msbN;
    Zflag = isZero;

    unique case (OP)
      4'b0000: Cflag = add_cout;        // ADD
      4'b0001: Cflag = ~sub_cout;       // SUB (¬borrow)
      4'b1000,
      4'b1001: Cflag = shft_c;          // SHIFT
      default: Cflag = 1'b0;
    endcase

    unique case (OP)
      4'b0000: Vflag = ((A[N-1]==B[N-1]) && (Rout[N-1]!=A[N-1]));
      4'b0001: Vflag = ((A[N-1]!=B[N-1]) && (Rout[N-1]!=A[N-1]));
      default: Vflag = 1'b0;
    endcase
  end
endmodule

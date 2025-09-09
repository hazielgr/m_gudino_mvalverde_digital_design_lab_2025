`timescale 1ns/1ps
module testBench;
    localparam int P = 4;

    logic [P-1:0] a, b;
    logic cin, bin;
    logic [P-1:0] sum, diff;
    logic cout, bout, N_sum, Z_sum, C_sum, V_sum, N_sub, Z_sub, C_sub, V_sub;

    sumador_Nbits #(.P(P)) UUT_ADD (
        .a(a), .b(b), .cin(cin),
        .sum(sum), .cout(cout),
        .N(N_sum), .Z(Z_sum), .C(C_sum), .V(V_sum)
    );

    restador_Nbits #(.P(P)) UUT_SUB (
        .a(a), .b(b), .bin(bin),
        .diff(diff), .bout(bout),
        .N(N_sub), .Z(Z_sub), .C(C_sub), .V(V_sub)
    );

    task run_case(input logic [P-1:0] A, input logic [P-1:0] B);
        begin
            a = A; b = B; cin = 0; bin = 0;
            #1;
            $display("A=%0d (%b), B=%0d (%b)", a, a, b, b);
            $display("SUMA: sum=%0d (%b) | N=%0b Z=%0b C=%0b V=%0b", sum, sum, N_sum, Z_sum, C_sum, V_sum);
            $display("RESTA: diff=%0d (%b) | N=%0b Z=%0b C=%0b V=%0b\n", diff, diff, N_sub, Z_sub, C_sub, V_sub);
        end
    endtask

    initial begin
        $display("===== TEST DE SUMADOR Y RESTADOR =====\n");

        run_case(4,4);
        run_case(4,15);
        run_case(7,1);
        run_case(0,0);
        run_case(4,12);
        run_case(8,3);
        run_case(12,4);

        #5 $stop;
    end
endmodule

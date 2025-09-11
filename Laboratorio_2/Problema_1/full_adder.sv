
module full_adder(
  input  logic a, b, cin,
  output logic sum, cout
);
  logic p, g, c1;
  xor1 ux1 (.a(a), .b(b),   .y(p));
  xor1 ux2 (.a(p), .b(cin), .y(sum));
  and1 ua1 (.a(a), .b(b),   .y(g));
  and1 ua2 (.a(p), .b(cin), .y(c1));
  or1  uo1 (.a(g), .b(c1),  .y(cout));
endmodule


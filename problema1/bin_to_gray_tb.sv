module bin_to_gray_tb;

  logic [3:0] bin;   // entrada binaria 
  logic [3:0] gray;  // salida del DUT
  logic [3:0] exp;   // salida esperada

  // módulo a probar (DUT)
  bin2gray dut (
    .B(bin),
    .G(gray)
  );

  // función para calcular el Gray esperado
  function automatic logic [3:0] expected(input logic [3:0] b);
    expected[3] = b[3];              
    expected[2] = b[3] ^ b[2];
    expected[1] = b[2] ^ b[1];
    expected[0] = b[1] ^ b[0];
  endfunction

  int pass = 0, fail = 0;  // contadores

  initial begin
    $display("BIN  | GRAY (DUT) | GRAY esperado | OK?");
    $display("--------------------------------------");

    // se prueban las entradas posibles de 0 a 15
    for (int i = 0; i < 16; i++) begin
      bin = i[3:0];   // asigna entrada
      #1;             
      exp = expected(bin); // calcula salida esperada

      if (gray === exp) begin
        pass++;
        $display("%b   |    %b     |     %b       | OK", bin, gray, exp);
      end else begin
        fail++;
        $display("%b   |    %b     |     %b       | FAIL", bin, gray, exp);
      end
    end

    $display("--------------------------------------");
    $display("TOTAL: PASS=%0d  FAIL=%0d", pass, fail);
    
  end

endmodule

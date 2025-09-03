`timescale 1ns/1ps

module counter_tb;

  
  reg clk2 = 0, clk4 = 0, clk6 = 0;
  always #5  clk2 = ~clk2;   // 100 MHz
  always #7  clk4 = ~clk4;   // 71.4 MHz
  always #11 clk6 = ~clk6;   // 45.5 MHz

  
  localparam bit VERBOSE = 1'b1;  

  task automatic print_state(string tag, int val, int tens, int ones);
    $display("[%0t] %s: q=%0d  (tens=%0d, ones=%0d)", $time, tag, val, tens, ones);
  endtask

  
  localparam int N2 = 2;
  reg               arst_n2, en2, load2;
  reg  [N2-1:0]     load_val2;
  wire [N2-1:0]     q2;
  wire [5:0]        q2_ext = {{(6-N2){1'b0}}, q2};
  wire [3:0]        tens2, ones2;

  counter #(.N(N2)) dut2 (
    .clk(clk2), .arst_n(arst_n2),
    .enable(en2), .load(load2), .load_value(load_val2),
    .q(q2)
  );

  bin_to_dec2digits dec2 (.bin(q2_ext), .tens(tens2), .ones(ones2));

  //  N = 4 
  localparam int N4 = 4;
  reg               arst_n4, en4, load4;
  reg  [N4-1:0]     load_val4;
  wire [N4-1:0]     q4;
  wire [5:0]        q4_ext = {{(6-N4){1'b0}}, q4};
  wire [3:0]        tens4, ones4;

  counter #(.N(N4)) dut4 (
    .clk(clk4), .arst_n(arst_n4),
    .enable(en4), .load(load4), .load_value(load_val4),
    .q(q4)
  );

  bin_to_dec2digits dec4 (.bin(q4_ext), .tens(tens4), .ones(ones4));

  //  N = 6
  localparam int N6 = 6;
  reg               arst_n6, en6, load6;
  reg  [N6-1:0]     load_val6;
  wire [N6-1:0]     q6;
  wire [5:0]        q6_ext = q6;
  wire [3:0]        tens6, ones6;

  counter #(.N(N6)) dut6 (
    .clk(clk6), .arst_n(arst_n6),
    .enable(en6), .load(load6), .load_value(load_val6),
    .q(q6)
  );

  bin_to_dec2digits dec6 (.bin(q6_ext), .tens(tens6), .ones(ones6));

  //  
  task pulse_1clk(input integer sel);
    case (sel)
      2: begin en2 = 1'b1; @(posedge clk2); en2 = 1'b0; end
      4: begin en4 = 1'b1; @(posedge clk4); en4 = 1'b0; end
      6: begin en6 = 1'b1; @(posedge clk6); en6 = 1'b0; end
    endcase
  endtask

  task pulse_load(input integer sel);
    case (sel)
      2: begin load2 = 1'b1; @(posedge clk2); load2 = 1'b0; end
      4: begin load4 = 1'b1; @(posedge clk4); load4 = 1'b0; end
      6: begin load6 = 1'b1; @(posedge clk6); load6 = 1'b0; end
    endcase
  endtask

  // TEST N = 2 
  initial begin : TEST_N2
    integer pass, fail, MOD, model;
    
    arst_n2   = 1'b1; en2 = 1'b0; load2 = 1'b0; load_val2 = '0;
    MOD = (1 << N2);

    // RESET asíncrono
    arst_n2 = 1'b0; @(posedge clk2); @(posedge clk2); arst_n2 = 1'b1; @(posedge clk2);
    pass = 0; fail = 0;
    if (q2===0) pass++; else begin fail++; $display("N=2 RESET FAIL: q=%0d", q2); end
    if (VERBOSE) print_state("N=2 AFTER RESET", q2_ext, tens2, ones2);

    // LOAD 0
    load_val2 = 0; pulse_load(2); @(posedge clk2);
    if (q2===0) begin
      pass++; if (VERBOSE) print_state("N=2 LOAD", q2_ext, tens2, ones2);
    end else begin
      fail++; $display("N=2 LOAD0 FAIL: q=%0d", q2);
    end

    // LOAD mitad
    load_val2 = MOD/2; pulse_load(2); @(posedge clk2);
    if (q2===MOD/2) begin
      pass++; if (VERBOSE) print_state("N=2 LOAD", q2_ext, tens2, ones2);
    end else begin
      fail++; $display("N=2 LOADmid FAIL: q=%0d", q2);
    end

    // LOAD max
    load_val2 = MOD-1; pulse_load(2); @(posedge clk2);
    if (q2===MOD-1) begin
      pass++; if (VERBOSE) print_state("N=2 LOAD", q2_ext, tens2, ones2);
    end else begin
      fail++; $display("N=2 LOADmax FAIL: q=%0d", q2);
    end

    // CONTEO + WRAP
    model = q2;
    repeat (MOD+2) begin
      pulse_1clk(2);
      model = (model + 1) % MOD;
      @(posedge clk2);
      if (q2===model) pass++; else begin fail++; $display("N=2 CNT FAIL: q=%0d exp=%0d", q2, model); end
      if (tens2===(model/10) && ones2===(model%10)) pass++; else begin fail++; $display("N=2 DEC FAIL: %0d -> %0d%0d", model, tens2, ones2); end
      if (VERBOSE && (model<2 || model==0))  // imprime al inicio y en wrap
        print_state("N=2 CNT", q2_ext, tens2, ones2);
    end
    $display("==== RESUMEN N=2: PASS=%0d FAIL=%0d ====", pass, fail);
  end

  //  TEST N = 4
  initial begin : TEST_N4
    integer pass, fail, MOD, model;
    arst_n4   = 1'b1; en4 = 1'b0; load4 = 1'b0; load_val4 = '0;
    MOD = (1 << N4);

    // RESET
    arst_n4 = 1'b0; @(posedge clk4); @(posedge clk4); arst_n4 = 1'b1; @(posedge clk4);
    pass = 0; fail = 0;
    if (q4===0) pass++; else begin fail++; $display("N=4 RESET FAIL: q=%0d", q4); end
    if (VERBOSE) print_state("N=4 AFTER RESET", q4_ext, tens4, ones4);

    // LOAD 0
    load_val4 = 0; pulse_load(4); @(posedge clk4);
    if (q4===0) begin
      pass++; if (VERBOSE) print_state("N=4 LOAD", q4_ext, tens4, ones4);
    end else begin
      fail++; $display("N=4 LOAD0 FAIL: q=%0d", q4);
    end

    // LOAD mitad (8)
    load_val4 = MOD/2; pulse_load(4); @(posedge clk4);
    if (q4===MOD/2) begin
      pass++; if (VERBOSE) print_state("N=4 LOAD", q4_ext, tens4, ones4);
    end else begin
      fail++; $display("N=4 LOADmid FAIL: q=%0d", q4);
    end

    // LOAD max (15)
    load_val4 = MOD-1; pulse_load(4); @(posedge clk4);
    if (q4===MOD-1) begin
      pass++; if (VERBOSE) print_state("N=4 LOAD", q4_ext, tens4, ones4);
    end else begin
      fail++; $display("N=4 LOADmax FAIL: q=%0d", q4);
    end

    // CONTEO + WRAP
    model = q4;
    repeat (MOD+3) begin
      pulse_1clk(4);
      model = (model + 1) % MOD;
      @(posedge clk4);
      if (q4===model) pass++; else begin fail++; $display("N=4 CNT FAIL: q=%0d exp=%0d", q4, model); end
      if (tens4===(model/10) && ones4===(model%10)) pass++; else begin fail++; $display("N=4 DEC FAIL: %0d -> %0d%0d", model, tens4, ones4); end
      if (VERBOSE && (model<3 || model==9 || model==10 || model>=15))
        print_state("N=4 CNT", q4_ext, tens4, ones4);
    end
    $display("==== RESUMEN N=4: PASS=%0d FAIL=%0d ====", pass, fail);
  end

  // TEST N = 6 
  initial begin : TEST_N6
    integer pass, fail, MOD, model;
    arst_n6   = 1'b1; en6 = 1'b0; load6 = 1'b0; load_val6 = '0;
    MOD = (1 << N6);

    // RESET
    arst_n6 = 1'b0; @(posedge clk6); @(posedge clk6); arst_n6 = 1'b1; @(posedge clk6);
    pass = 0; fail = 0;
    if (q6===0) pass++; else begin fail++; $display("N=6 RESET FAIL: q=%0d", q6); end
    if (VERBOSE) print_state("N=6 AFTER RESET", q6_ext, tens6, ones6);

    // LOAD 0
    load_val6 = 0; pulse_load(6); @(posedge clk6);
    if (q6===0) begin
      pass++; if (VERBOSE) print_state("N=6 LOAD", q6_ext, tens6, ones6);
    end else begin
      fail++; $display("N=6 LOAD0 FAIL: q=%0d", q6);
    end

    // LOAD 31
    load_val6 = 31; pulse_load(6); @(posedge clk6);
    if (q6===31) begin
      pass++; if (VERBOSE) print_state("N=6 LOAD", q6_ext, tens6, ones6);
    end else begin
      fail++; $display("N=6 LOAD31 FAIL: q=%0d", q6);
    end

    // LOAD 63
    load_val6 = 63; pulse_load(6); @(posedge clk6);
    if (q6===63) begin
      pass++; if (VERBOSE) print_state("N=6 LOAD", q6_ext, tens6, ones6);
    end else begin
      fail++; $display("N=6 LOAD63 FAIL: q=%0d", q6);
    end

    // CONTEO + WRAP
    model = q6;
    repeat (MOD+3) begin
      pulse_1clk(6);
      model = (model + 1) % MOD;
      @(posedge clk6);
      if (q6===model) pass++; else begin fail++; $display("N=6 CNT FAIL: q=%0d exp=%0d", q6, model); end
      if (tens6===(model/10) && ones6===(model%10)) pass++; else begin fail++; $display("N=6 DEC FAIL: %0d -> %0d%0d", model, tens6, ones6); end
      if (VERBOSE)  // imprime cada paso para N=6
        print_state("N=6 CNT", q6_ext, tens6, ones6);
    end
    $display("==== RESUMEN N=6: PASS=%0d FAIL=%0d ====", pass, fail);

    $finish;
  end

endmodule

module btn_debouncer #(
  parameter int CNT = 16
)(
  input  logic clk,
  input  logic btn_n,
  output logic btn_clean
);
  logic [CNT-1:0] sr;
  always_ff @(posedge clk) begin
    sr <= {sr[CNT-2:0], ~btn_n};
  end
  assign btn_clean = &sr;
endmodule

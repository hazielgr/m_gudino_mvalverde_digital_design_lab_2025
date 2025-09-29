module btn_one_pulse #(
    parameter int CNTR_BITS = 19   // ~10 ms @ 50 MHz
)(
    input  logic clk,
    input  logic rst_n,
    input  logic btn_raw,
    output logic pulse
);
    // 2-FF sync
    logic s0, s1;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) {s0,s1} <= 2'b00;
        else         {s0,s1} <= {btn_raw, s0};
    end
    // debounce by stability
    logic [CNTR_BITS-1:0] db_cnt;
    logic stable, debounced;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            db_cnt <= '0; stable <= 1'b0; debounced <= 1'b0;
        end else begin
            if (s1 != stable) db_cnt <= '0;
            else if (db_cnt != {CNTR_BITS{1'b1}}) db_cnt <= db_cnt + 1'b1;
            if (db_cnt == {CNTR_BITS{1'b1}}) debounced <= stable;
            stable <= s1;
        end
    end
    // rising-edge detect
    logic d_q;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) d_q <= 1'b0;
        else        d_q <= debounced;
    end
    assign pulse = debounced & ~d_q;
endmodule

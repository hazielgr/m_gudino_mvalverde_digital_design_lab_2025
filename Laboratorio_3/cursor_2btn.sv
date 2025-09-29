module cursor_2btn (
    input  logic clk,
    input  logic rst_n,
    input  logic row_pulse,     // advance row (0..3)
    input  logic col_pulse,     // advance col (0..3)
    output logic [1:0] sel_row,
    output logic [1:0] sel_col
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sel_row <= 2'd0;
            sel_col <= 2'd0;
        end else begin
            if (row_pulse) sel_row <= sel_row + 2'd1; // wraps 3->0
            if (col_pulse) sel_col <= sel_col + 2'd1;
        end
    end
endmodule

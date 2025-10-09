// ============================================================
// autopick.sv — pick first valid index on 15s timeout (one-cycle auto_valid)
// No mixed blocking/nonblocking on same variable.
// ============================================================
module autopick #(
    parameter int N_CARDS = 16,
    parameter int IDX_W   = 4
) (
    input  logic                 clk,
    input  logic                 rst_n,

    input  logic                 timer15_done,   // level; we edge-detect
    input  logic [N_CARDS-1:0]   matched_mask,
    input  logic [N_CARDS-1:0]   revealed_mask,

    input  logic                 exclude_valid,  // avoid picking this one (2nd pick case)
    input  logic [IDX_W-1:0]     exclude_idx,

    output logic                 auto_valid,     // 1 cycle when a pick is made
    output logic [IDX_W-1:0]     auto_idx
);
    // Edge-detect timer15_done
    logic t15_q;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) t15_q <= 1'b0;
        else        t15_q <= timer15_done;
    end
    wire t15_pulse = timer15_done & ~t15_q;

    // One-cycle fire on t15_pulse
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            auto_valid <= 1'b0;
            auto_idx   <= '0;
        end else begin
            auto_valid <= 1'b0; // default

            if (t15_pulse) begin
                automatic logic [IDX_W-1:0] pick  = '0;
                automatic bit               got   = 1'b0;

                for (int i = 0; i < N_CARDS; i++) begin
                    if (!matched_mask[i] && !revealed_mask[i]) begin
                        if (!exclude_valid || i[IDX_W-1:0] != exclude_idx) begin
                            if (!got) begin
                                pick = i[IDX_W-1:0];
                                got  = 1'b1;
                            end
                        end
                    end
                end

                if (got) begin
                    auto_idx   <= pick;     // commit
                    auto_valid <= 1'b1;     // pulse
                end
            end
        end
    end
endmodule

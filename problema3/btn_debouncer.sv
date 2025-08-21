module btn_debouncer #(
    parameter int CYCLES = 250_000  
)(
    input  logic clk,
    input  logic rst_n,     // reset síncrono 
    input  logic noisy_in,  // señal cruda del botón 
    output logic clean_out  // señal estable, sin rebotes
);
    // sincronizador 2 FF
    logic s0, s1;
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            s0 <= 1'b0;
            s1 <= 1'b0;
        end else begin
            s0 <= noisy_in;
            s1 <= s0;
        end
    end

    // contador de estabilidad y estado limpio
    logic [$clog2(CYCLES):0] cnt;
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            clean_out <= 1'b0;
            cnt       <= '0;
        end else begin
            if (s1 == clean_out) begin
                // resetea contador
                cnt <= '0;
            end else begin
                // cuenta estabilidad
                if (cnt == CYCLES) begin
                    clean_out <= s1;   
                    cnt       <= '0;
                end else begin
                    cnt <= cnt + 1'b1;
                end
            end
        end
    end
endmodule

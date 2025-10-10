// =============================================================
// winner_overlay.sv
// Minimal VGA text overlay: shows "P1", "P2", or "TIE" at game over.
// Passive: it only renders when gameover=1; otherwise passes RGB through.
// Letters used: P, 1, 2, T, I, E (5x7 font, scalable).
// =============================================================
module winner_overlay #(
    parameter int H_RES = 640,
    parameter int V_RES = 480,
    // 5x7 font parameters
    parameter int CHAR_W = 5,
    parameter int CHAR_H = 7,
    parameter int SCALE  = 3,   // scale factor per font pixel
    parameter int GAP    = 1    // gap (in font pixels) between characters
)(
    input  logic        video_on,             // active video area
    input  logic [9:0]  px,                   // current pixel x (0..H_RES-1)
    input  logic [9:0]  py,                   // current pixel y (0..V_RES-1)

    // Base RGB from your renderer
    input  logic [7:0]  base_r,
    input  logic [7:0]  base_g,
    input  logic [7:0]  base_b,

    // FSM-owned status
    input  logic        gameover,             // 1 = all pairs found (FSM S_GAMEOVER)
    input  logic [1:0]  winner,               // 0=P1, 1=P2, 2=TIE

    // Final RGB (overlay applied)
    output logic [7:0]  r,
    output logic [7:0]  g,
    output logic [7:0]  b
);

    // ---------- 5x7 font bitmaps for P,1,2,T,I,E ----------
    function automatic logic font_px(input byte ch, input int cx, input int cy);
        // Each row is 5 bits, MSB is x=0
        localparam logic [4:0] P_ROW [0:6] = '{
            5'b11110, 5'b10001, 5'b10001, 5'b11110, 5'b10000, 5'b10000, 5'b10000
        };
        localparam logic [4:0] ONE_ROW [0:6] = '{
            5'b00100, 5'b01100, 5'b00100, 5'b00100, 5'b00100, 5'b00100, 5'b01110
        };
        localparam logic [4:0] TWO_ROW [0:6] = '{
            5'b01110, 5'b10001, 5'b00001, 5'b00110, 5'b01000, 5'b10000, 5'b11111
        };
        localparam logic [4:0] T_ROW [0:6] = '{
            5'b11111, 5'b00100, 5'b00100, 5'b00100, 5'b00100, 5'b00100, 5'b00100
        };
        localparam logic [4:0] I_ROW [0:6] = '{
            5'b11111, 5'b00100, 5'b00100, 5'b00100, 5'b00100, 5'b00100, 5'b11111
        };
        localparam logic [4:0] E_ROW [0:6] = '{
            5'b11111, 5'b10000, 5'b10000, 5'b11110, 5'b10000, 5'b10000, 5'b11111
        };

        if (cx < 0 || cx > 4 || cy < 0 || cy > 6) return 1'b0;
        unique case (ch)
            "P": return P_ROW  [cy][4-cx];
            "1": return ONE_ROW[cy][4-cx];
            "2": return TWO_ROW[cy][4-cx];
            "T": return T_ROW  [cy][4-cx];
            "I": return I_ROW  [cy][4-cx];
            "E": return E_ROW  [cy][4-cx];
            default: return 1'b0;
        endcase
    endfunction

    // Build message from winner
    localparam int MAX_LEN = 3;
    byte msg [0:MAX_LEN-1];
    int  msg_len;

    always_comb begin
        msg[0]="T"; msg[1]="I"; msg[2]="E"; msg_len=3;
        unique case (winner)
            2'd0: begin msg[0]="P"; msg[1]="1"; msg_len=2; end // P1
            2'd1: begin msg[0]="P"; msg[1]="2"; msg_len=2; end // P2
            2'd2: begin msg[0]="T"; msg[1]="I"; msg[2]="E"; msg_len=3; end // TIE
            default: ;
        endcase
    end

    // Dimensions and centering
    localparam int CELL_W = CHAR_W * SCALE;
    localparam int CELL_H = CHAR_H * SCALE;
    localparam int GAP_S  = GAP * SCALE;

    int total_w, x0, y0;
    always_comb begin
        total_w = (msg_len * CELL_W) + ((msg_len > 0 ? msg_len-1 : 0) * GAP_S);
        x0 = (H_RES - total_w) >>> 1;
        y0 = (V_RES - CELL_H) >>> 1;
    end

    // Dim background slightly at gameover
    logic [7:0] bg_r, bg_g, bg_b;
    always_comb begin
        if (gameover && video_on) begin
            bg_r = {1'b0, base_r[7:1]};
            bg_g = {1'b0, base_g[7:1]};
            bg_b = {1'b0, base_b[7:1]};
        end else begin
            bg_r = base_r; bg_g = base_g; bg_b = base_b;
        end
    end

    // Text color (gold-ish)
    localparam logic [7:0] TXT_R = 8'd255, TXT_G = 8'd220, TXT_B = 8'd0;

    // Hit test
    logic hit_text;
    always_comb begin
        hit_text = 1'b0;
        if (gameover && video_on &&
            (px >= x0) && (px < x0 + total_w) &&
            (py >= y0) && (py < y0 + CELL_H)) begin

            int relx = px - x0;
            int rely = py - y0;
            int acc = 0;

            for (int i = 0; i < msg_len; i++) begin
                int char_x0 = acc;
                if (relx >= char_x0 && relx < char_x0 + CELL_W) begin
                    int cx = (relx - char_x0) / SCALE;
                    int cy = (rely) / SCALE;
                    if (font_px(msg[i], cx, cy)) begin
                        hit_text = 1'b1;
                    end
                end
                acc += CELL_W + GAP_S;
            end
        end
    end

    // Output mux
    always_comb begin
        if (hit_text) {r,g,b} = {TXT_R, TXT_G, TXT_B};
        else          {r,g,b} = {bg_r , bg_g , bg_b };
    end

endmodule

// grid_renderer_icons.sv — 4×4 cards inside gray frame + gutters,
// with 8 procedural "Mario-ish" icons (no external files).
module grid_renderer_icons (
    input  logic        video_on,
    input  logic [9:0]  x, y,
    input  logic [1:0]  sel_row, sel_col,
    output logic [7:0]  R, G, B
);
    // ===== Layout =====
    localparam int FRAME   = 16;
    localparam int GRID_W  = 640 - 2*FRAME;     // 608
    localparam int GRID_H  = 480 - 2*FRAME;     // 448
    localparam int GUTTER  = 8;

    localparam int CARD_W  = (GRID_W - 3*GUTTER)/4;  // 146
    localparam int CARD_H  = (GRID_H - 3*GUTTER)/4;  // 106
    localparam int CELL_W  = CARD_W + GUTTER;        // 154
    localparam int CELL_H  = CARD_H + GUTTER;        // 114
    localparam int BORDER  = 3;

    // Sprite area inside each card
    localparam int SPR_W   = 64;
    localparam int SPR_H   = 64;
    localparam int SPR_OX  = (CARD_W - SPR_W)/2;     // 41
    localparam int SPR_OY  = (CARD_H - SPR_H)/2;     // 21

    // Colors
    localparam logic [7:0] GRAY_FRAME_R = 8'd48,  GRAY_FRAME_G = 8'd48,  GRAY_FRAME_B = 8'd48;
    localparam logic [7:0] GRAY_CARD_R  = 8'd200, GRAY_CARD_G  = 8'd200, GRAY_CARD_B  = 8'd200;
    localparam logic [7:0] BLACK_R      = 8'd0,   BLACK_G      = 8'd0,   BLACK_B      = 8'd0;

    localparam logic [7:0] YEL_R=8'd255, YEL_G=8'd210, YEL_B=8'd40;
    localparam logic [7:0] RED_R=8'd220, RED_G=8'd40,  RED_B=8'd30;
    localparam logic [7:0] GRN_R=8'd40,  GRN_G=8'd200, GRN_B=8'd60;
    localparam logic [7:0] BRN_R=8'd130, BRN_G=8'd80,  BRN_B=8'd30;
    localparam logic [7:0] ORG_R=8'd240, ORG_G=8'd120, ORG_B=8'd30;
    localparam logic [7:0] WHT_R=8'd255, WHT_G=8'd255, WHT_B=8'd255;
    localparam logic [7:0] OLV_R=8'd90,  OLV_G=8'd110, OLV_B=8'd30;

    // ===== Small helpers =====
    function automatic int iabs(input int v); iabs = (v<0)?-v:v; endfunction
    function automatic bit in_rect(input int px,py,x0,y0,w,h);
        in_rect = (px>=x0) && (px<x0+w) && (py>=y0) && (py<y0+h);
    endfunction
    function automatic bit in_circle(input int px,py,cx,cy,r);
        int dx = px-cx; int dy = py-cy;
        in_circle = (dx*dx + dy*dy) <= (r*r);
    endfunction

    // ===== Region decoding (NO decl-assigns) =====
    logic in_vis;
    assign in_vis = video_on;

    logic in_frame;
    assign in_frame = (x >= FRAME) && (x < FRAME + GRID_W) &&
                      (y >= FRAME) && (y < FRAME + GRID_H);

    logic [9:0] gx, gy;
    assign gx = x - FRAME;
    assign gy = y - FRAME;

    logic [1:0] card_c, card_r;
    assign card_c = gx / CELL_W;   // 0..3
    assign card_r = gy / CELL_H;   // 0..3

    logic [8:0] lx;
    logic [7:0] ly;
    assign lx = gx - card_c * CELL_W;  // 0..153
    assign ly = gy - card_r * CELL_H;  // 0..113

    logic in_card_rect;
    assign in_card_rect = (lx < CARD_W) && (ly < CARD_H);

    logic selected_cell;
    assign selected_cell = (card_r == sel_row) && (card_c == sel_col);

    logic in_border;
    assign in_border = selected_cell && in_card_rect &&
                       ( (lx < BORDER) || (lx >= CARD_W - BORDER) ||
                         (ly < BORDER) || (ly >= CARD_H - BORDER) );

    // sprite-local signed coords
    logic signed [10:0] sx, sy;  // enough for -64..+191
    always_comb begin
        sx = $signed({1'b0,lx}) - SPR_OX;
        sy = $signed({1'b0,ly}) - SPR_OY;
    end

    logic in_sprite;
    assign in_sprite = in_card_rect && (sx >= 0) && (sx < SPR_W) &&
                                     (sy >= 0) && (sy < SPR_H);

    // Pair mapping (8 icons)
    logic [2:0] icon_id;
    always_comb begin
        case (card_r)
            2'd0, 2'd2: icon_id = {1'b0, card_c};  // 0..3
            default   : icon_id = 3'd4 + card_c;   // 4..7
        endcase
    end

    // ===== Icon drawer =====
    logic px_opaque;
    logic [7:0] sr, sg, sb;

    always_comb begin
        px_opaque = 1'b0; sr = 8'd0; sg = 8'd0; sb = 8'd0;

        if (in_sprite) begin
            unique case (icon_id)
                // 0: QUESTION BLOCK
                3'd0: begin
                    if (in_rect(sx,sy,2,2,60,60) && !in_rect(sx,sy,6,6,52,52)) begin
                        px_opaque=1; sr=8'd80; sg=8'd60; sb=8'd10;
                    end else if (in_rect(sx,sy,6,6,52,52)) begin
                        px_opaque=1; sr=YEL_R; sg=YEL_G; sb=YEL_B;
                    end
                    if ( in_rect(sx,sy,22,16,20,8) || in_rect(sx,sy,34,24,8,12) ||
                         in_rect(sx,sy,22,36,20,8) || in_rect(sx,sy,28,48,8,8) ) begin
                        px_opaque=1; sr=8'd40; sg=8'd40; sb=8'd40;
                    end
                end

                // 1: RED MUSHROOM
                3'd1: begin
                    if (in_circle(sx,sy,32,28,24) && (sy<=28+6)) begin
                        px_opaque=1; sr=RED_R; sg=RED_G; sb=RED_B;
                    end else if (in_rect(sx,sy,16,34,32,14)) begin
                        px_opaque=1; sr=8'd240; sg=8'd220; sb=8'd160;
                    end
                    if (in_circle(sx,sy,22,24,6) || in_circle(sx,sy,42,24,6) ||
                        in_circle(sx,sy,32,18,7)) begin
                        px_opaque=1; sr=WHT_R; sg=WHT_G; sb=WHT_B;
                    end
                    if (in_rect(sx,sy,26,38,4,8) || in_rect(sx,sy,34,38,4,8)) begin
                        px_opaque=1; sr=0; sg=0; sb=0;
                    end
                end

                // 2: COIN
                3'd2: begin
                    if (in_circle(sx,sy,32,32,24)) begin
                        px_opaque=1; sr=YEL_R; sg=YEL_G; sb=YEL_B;
                    end
                    if (in_circle(sx,sy,32,32,24) && in_rect(sx,sy,34,12,6,40)) begin
                        px_opaque=1; sr=8'd255; sg=8'd240; sb=8'd120;
                    end
                    if (in_circle(sx,sy,32,32,24) && in_rect(sx,sy,40,14,4,36)) begin
                        px_opaque=1; sr=8'd255; sg=8'd255; sb=8'd180;
                    end
                end

                // 3: STAR
                3'd3: begin
                    if (in_rect(sx,sy,28,12,8,40) || in_rect(sx,sy,12,28,40,8) ||
                        (iabs(sx-32)+iabs(sy-20) < 16) || (iabs(sx-32)+iabs(sy-44) < 16)) begin
                        px_opaque=1; sr=8'd255; sg=8'd230; sb=8'd70;
                    end
                    if (in_rect(sx,sy,24,30,3,8) || in_rect(sx,sy,35,30,3,8)) begin
                        px_opaque=1; sr=0; sg=0; sb=0;
                    end
                end

                // 4: GREEN 1-UP MUSHROOM
                3'd4: begin
                    if (in_circle(sx,sy,32,28,24) && (sy<=28+6)) begin
                        px_opaque=1; sr=GRN_R; sg=GRN_G; sb=GRN_B;
                    end else if (in_rect(sx,sy,16,34,32,14)) begin
                        px_opaque=1; sr=8'd240; sg=8'd220; sb=8'd160;
                    end
                    if (in_circle(sx,sy,22,24,6) || in_circle(sx,sy,42,24,6) ||
                        in_circle(sx,sy,32,18,7)) begin
                        px_opaque=1; sr=WHT_R; sg=WHT_G; sb=WHT_B;
                    end
                    if (in_rect(sx,sy,26,38,4,8) || in_rect(sx,sy,34,38,4,8)) begin
                        px_opaque=1; sr=0; sg=0; sb=0;
                    end
                end

                // 5: GOOMBA
                3'd5: begin
                    if ( ((sx-32)*(sx-32)) + ((sy-30)*(sy-30)*3)/2 <= (24*24) ) begin
                        px_opaque=1; sr=BRN_R; sg=BRN_G; sb=BRN_B;
                    end else if (in_rect(sx,sy,14,50,16,8) || in_rect(sx,sy,34,50,16,8)) begin
                        px_opaque=1; sr=8'd80; sg=8'd50; sb=8'd20;
                    end
                    if (in_rect(sx,sy,22,28,6,10) || in_rect(sx,sy,36,28,6,10) ||
                        in_rect(sx,sy,18,24,14,3) || in_rect(sx,sy,32,24,14,3) ||
                        in_rect(sx,sy,26,44,12,3)) begin
                        px_opaque=1; sr=0; sg=0; sb=0;
                    end
                end

                // 6: FIRE FLOWER
                3'd6: begin
                    if (in_circle(sx,sy,32,28,22)) begin
                        px_opaque=1; sr=ORG_R; sg=ORG_G; sb=ORG_B;
                    end
                    if (in_circle(sx,sy,32,28,14)) begin
                        px_opaque=1; sr=YEL_R; sg=YEL_G; sb=YEL_B;
                    end
                    if (in_rect(sx,sy,27,26,4,8) || in_rect(sx,sy,35,26,4,8)) begin
                        px_opaque=1; sr=0; sg=0; sb=0;
                    end
                    if (in_rect(sx,sy,30,44,4,16) || in_rect(sx,sy,22,48,10,4) ||
                        in_rect(sx,sy,34,48,10,4)) begin
                        px_opaque=1; sr=OLV_R; sg=OLV_G; sb=OLV_B;
                    end
                end

                // 7: "M" AVATAR
                default: begin
                    if (in_rect(sx,sy,4,8,56,20)) begin
                        px_opaque=1; sr=RED_R; sg=RED_G; sb=RED_B;
                    end
                    if (in_rect(sx,sy,10,12,6,20) || in_rect(sx,sy,48,12,6,20) ||
                        in_rect(sx,sy,22,12,6,12) || in_rect(sx,sy,36,12,6,12)) begin
                        px_opaque=1; sr=WHT_R; sg=WHT_G; sb=WHT_B;
                    end
                    if (in_rect(sx,sy,10,34,44,24)) begin
                        px_opaque=1; sr=8'd180; sg=8'd30; sb=8'd30;
                    end
                    if (in_rect(sx,sy,22,44,6,6) || in_rect(sx,sy,38,44,6,6)) begin
                        px_opaque=1; sr=YEL_R; sg=YEL_G; sb=YEL_B;
                    end
                end
            endcase
        end
    end

    // ===== Final color mux =====
    always_comb begin
        if (!in_vis) begin
            R=BLACK_R; G=BLACK_G; B=BLACK_B;
        end else if (!in_frame) begin
            R=GRAY_FRAME_R; G=GRAY_FRAME_G; B=GRAY_FRAME_B;   // outer frame
        end else if (!in_card_rect) begin
            R=GRAY_FRAME_R; G=GRAY_FRAME_G; B=GRAY_FRAME_B;   // gutters
        end else if (in_border) begin
            R=8'd255; G=8'd255; B=8'd0;                       // selection border
        end else if (px_opaque) begin
            R=sr; G=sg; B=sb;                                 // icon pixel
        end else begin
            R=GRAY_CARD_R; G=GRAY_CARD_G; B=GRAY_CARD_B;      // card background
        end
    end
endmodule
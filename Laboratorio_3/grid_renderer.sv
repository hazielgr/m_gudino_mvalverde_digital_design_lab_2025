// grid_renderer_icons.sv — 4×4 cards inside gray frame + gutters,
// with 8 procedural "Mario-ish" icons (no external files).
module grid_renderer_icons (
    input  logic        video_on,
    input  logic [9:0]  x, y,
    input  logic [1:0]  sel_row, sel_col,
    output logic [7:0]  R, G, B
);
    // ===== Layout (same look) =====
    localparam int FRAME   = 16;
    localparam int GRID_W  = 640 - 2*FRAME;     // 608
    localparam int GRID_H  = 480 - 2*FRAME;     // 448
    localparam int GUTTER  = 8;

    localparam int CARD_W  = (GRID_W - 3*GUTTER)/4;  // 146
    localparam int CARD_H  = (GRID_H - 3*GUTTER)/4;  // 106
    localparam int CELL_W  = CARD_W + GUTTER;        // 154
    localparam int CELL_H  = CARD_H + GUTTER;        // 114
    localparam int BORDER  = 3;

    // "Sprite" logical area per card (we draw inside this box)
    localparam int SPR_W   = 64;
    localparam int SPR_H   = 64;
    localparam int SPR_OX  = (CARD_W - SPR_W)/2;
    localparam int SPR_OY  = (CARD_H - SPR_H)/2;

    // Colors
    localparam logic [7:0] GRAY_FRAME = 8'd48;
    localparam logic [7:0] GRAY_CARD  = 8'd200;
    localparam logic [7:0] BLACK      = 8'd0;

    // helper functions
    function automatic int iabs(input int v); iabs = (v<0)?-v:v; endfunction
    function automatic bit in_rect(input int px,py,x0,y0,w,h);
        return (px>=x0) && (px<x0+w) && (py>=y0) && (py<y0+h);
    endfunction
    function automatic bit in_circle(input int px,py,cx,cy,r);
        int dx = px-cx; int dy = py-cy;
        return (dx*dx + dy*dy) <= (r*r);
    endfunction

    // visible?
    logic in_vis = video_on;

    // inside outer frame?
    logic in_frame = (x >= FRAME) && (x < FRAME + GRID_W) &&
                     (y >= FRAME) && (y < FRAME + GRID_H);

    // frame-local coords
    logic [9:0] gx = x - FRAME;
    logic [9:0] gy = y - FRAME;

    // which cell (0..3)
    logic [1:0] card_c = gx / CELL_W;
    logic [1:0] card_r = gy / CELL_H;

    // local coords inside the cell
    logic [8:0] lx = gx - card_c * CELL_W; // 0..153
    logic [7:0] ly = gy - card_r * CELL_H; // 0..113

    // card rect (not gutter)
    logic in_card_rect = (lx < CARD_W) && (ly < CARD_H);

    // selection border
    logic selected_cell = (card_r == sel_row) && (card_c == sel_col);
    logic in_border = selected_cell && in_card_rect &&
                      ( (lx < BORDER) || (lx >= CARD_W - BORDER) ||
                        (ly < BORDER) || (ly >= CARD_H - BORDER) );

    // sprite-local coords (centered 64×64 region)
    int sx = int'(lx) - SPR_OX;
    int sy = int'(ly) - SPR_OY;
    logic in_sprite = in_card_rect && (sx >= 0) && (sx < SPR_W) &&
                                      (sy >= 0) && (sy < SPR_H);

    // map cells to 8 icon IDs (paired across rows)
    logic [2:0] icon_id;
    always_comb begin
        case (card_r)
            2'd0, 2'd2: icon_id = {1'b0, card_c};  // 0..3
            default   : icon_id = 3'd4 + card_c;   // 4..7
        endcase
    end

    // ===== Procedural icon drawer =====
    // Returns opaque flag + RGB (8-bit channels).
    function automatic void draw_icon(
        input  [2:0] id, input int u, v,
        output logic opaque,
        output logic [7:0] r,g,b
    );
        // default transparent
        opaque = 1'b0; r=8'd0; g=8'd0; b=8'd0;

        // handy palette
        logic [7:0] YEL [0:2]; initial begin YEL[0]=8'd255; YEL[1]=8'd210; YEL[2]=8'd40; end
        logic [7:0] RED [0:2]; initial begin RED[0]=8'd220; RED[1]=8'd40;  RED[2]=8'd30; end
        logic [7:0] GRN [0:2]; initial begin GRN[0]=8'd40;  GRN[1]=8'd200; GRN[2]=8'd60; end
        logic [7:0] BRN [0:2]; initial begin BRN[0]=8'd130; BRN[1]=8'd80;  BRN[2]=8'd30; end
        logic [7:0] ORG [0:2]; initial begin ORG[0]=8'd240; ORG[1]=8'd120; ORG[2]=8'd30; end
        logic [7:0] WHT [0:2]; initial begin WHT[0]=8'd255; WHT[1]=8'd255; WHT[2]=8'd255; end
        logic [7:0] OLV [0:2]; initial begin OLV[0]=8'd90;  OLV[1]=8'd110; OLV[2]=8'd30; end

        // helper to set color
        automatic void setc(input logic [7:0] cr,cg,cb);
            opaque=1'b1; r=cr; g=cg; b=cb;
        end

        // bounding box for icons
        bit in_box = in_rect(u,v, 2,2, 60,60);

        unique case (id)
            // 0: QUESTION BLOCK (gold square + question mark)
            3'd0: begin
                if (!in_box) begin end
                else if (in_rect(u,v,2,2,60,60) && !in_rect(u,v,6,6,52,52)) setc(8'd80,8'd60,8'd10); // border
                else if (in_rect(u,v,6,6,52,52)) setc(YEL[0],YEL[1],YEL[2]);                        // fill
                // question mark (blocky)
                else if ( in_rect(u,v,22,16,20,8) ||                             // top bar
                          in_rect(u,v,34,24,8,12) ||                              // right down
                          in_rect(u,v,22,36,20,8) ||                              // mid bar
                          in_rect(u,v,28,48,8,8) ) setc(8'd40,8'd40,8'd40);
            end

            // 1: RED MUSHROOM (cap + stem + dots)
            3'd1: begin
                int cx=32, cy=28;
                if (in_circle(u,v,cx,cy,24) && (v<=cy+6)) setc(RED[0],RED[1],RED[2]);        // cap
                else if (in_rect(u,v,16,34,32,14)) setc(8'd240,8'd220,8'd160);               // stem
                // dots on cap
                else if (in_circle(u,v,22,24,6) || in_circle(u,v,42,24,6) ||
                         in_circle(u,v,32,18,7)) setc(WHT[0],WHT[1],WHT[2]);
                // eyes
                else if (in_rect(u,v,26,38,4,8) || in_rect(u,v,34,38,4,8)) setc(0,0,0);
            end

            // 2: COIN (yellow circle with shine)
            3'd2: begin
                int cx=32, cy=32;
                if (in_circle(u,v,cx,cy,24)) setc(YEL[0],YEL[1],YEL[2]);
                if (in_circle(u,v,cx,cy,24) && in_rect(u,v,34,12,6,40)) setc(8'd255,8'd240,8'd120); // stripe
                if (in_circle(u,v,cx,cy,24) && in_rect(u,v,40,14,4,36)) setc(8'd255,8'd255,8'd180); // shine
            end

            // 3: STAR (five-ish points made from cross + diagonals)
            3'd3: begin
                int cx=32, cy=32;
                // cross
                if (in_rect(u,v,28,12,8,40) || in_rect(u,v,12,28,40,8)) setc(8'd255,8'd230,8'd70);
                // diagonals (diamond arms)
                else if (iabs((u-32)) + iabs((v-20)) < 16 ||
                         iabs((u-32)) + iabs((v-44)) < 16) setc(8'd255,8'd230,8'd70);
                // eyes
                if (in_rect(u,v,24,30,3,8) || in_rect(u,v,35,30,3,8)) setc(0,0,0);
            end

            // 4: GREEN 1-UP MUSHROOM (same as red but green)
            3'd4: begin
                int cx=32, cy=28;
                if (in_circle(u,v,cx,cy,24) && (v<=cy+6)) setc(GRN[1],GRN[2],GRN[0]);
                else if (in_rect(u,v,16,34,32,14)) setc(8'd240,8'd220,8'd160);
                else if (in_circle(u,v,22,24,6) || in_circle(u,v,42,24,6) ||
                         in_circle(u,v,32,18,7)) setc(WHT[0],WHT[1],WHT[2]);
                else if (in_rect(u,v,26,38,4,8) || in_rect(u,v,34,38,4,8)) setc(0,0,0);
            end

            // 5: GOOMBA (brown oval + eyes + frown)
            3'd5: begin
                // oval body approx via stretched circle test
                int ux = (u-32), vy = (v-30);
                if ( ( (ux*ux) + (vy*vy*3)/2 ) <= (24*24) ) setc(BRN[0],BRN[1],BRN[2]);
                // feet
                else if (in_rect(u,v,14,50,16,8) || in_rect(u,v,34,50,16,8)) setc(8'd80,8'd50,8'd20);
                // eyes and brows
                else if (in_rect(u,v,22,28,6,10) || in_rect(u,v,36,28,6,10)) setc(0,0,0);
                else if (in_rect(u,v,18,24,14,3) || in_rect(u,v,32,24,14,3)) setc(0,0,0);
                // mouth
                else if (in_rect(u,v,26,44,12,3)) setc(0,0,0);
            end

            // 6: FIRE FLOWER (petals + center + stem)
            3'd6: begin
                int cx=32, cy=28;
                if (in_circle(u,v,cx,cy,22)) setc(ORG[0],ORG[1],ORG[2]);           // petals
                if (in_circle(u,v,cx,cy,14)) setc(YEL[0],YEL[1],YEL[2]);           // center
                // eyes on center
                if (in_rect(u,v,27,26,4,8) || in_rect(u,v,35,26,4,8)) setc(0,0,0);
                // stem + leaves
                if (in_rect(u,v,30,44,4,16)) setc(OLV[0],OLV[1],OLV[2]);
                if (in_rect(u,v,22,48,10,4) || in_rect(u,v,34,48,10,4)) setc(OLV[0],OLV[1],OLV[2]);
            end

            // 7: SIMPLE "M" AVATAR (hat + overalls-ish)
            default: begin
                if (in_rect(u,v,4,8,56,20)) setc(RED[0],RED[1],RED[2]);            // hat
                // M letter
                if (in_rect(u,v,10,12,6,20) || in_rect(u,v,48,12,6,20) ||
                    in_rect(u,v,22,12,6,12) || in_rect(u,v,36,12,6,12)) setc(255,255,255);
                // body
                if (in_rect(u,v,10,34,44,24)) setc(8'd180,8'd30,8'd30);            // clothes
                // buttons
                if (in_rect(u,v,22,44,6,6) || in_rect(u,v,38,44,6,6)) setc(YEL[0],YEL[1],YEL[2]);
            end
        endcase
    endfunction

    // draw one pixel from icon set
    logic px_opaque;
    logic [7:0] sr,sg,sb;
    always_comb begin
        px_opaque = 1'b0; sr=0; sg=0; sb=0;
        if (in_sprite) draw_icon(icon_id, sx, sy, px_opaque, sr, sg, sb);
    end

    // ===== Final color selection =====
    always_comb begin
        if (!in_vis) begin
            R=BLACK; G=BLACK; B=BLACK;
        end else if (!in_frame) begin
            R=GRAY_FRAME; G=GRAY_FRAME; B=GRAY_FRAME;          // outer frame
        end else if (!in_card_rect) begin
            R=GRAY_FRAME; G=GRAY_FRAME; B=GRAY_FRAME;          // gutters
        end else if (in_border) begin
            R=8'd255; G=8'd255; B=8'd0;                        // selection border
        end else if (px_opaque) begin
            R=sr; G=sg; B=sb;                                   // icon pixel
        end else begin
            R=GRAY_CARD; G=GRAY_CARD; B=GRAY_CARD;             // card background
        end
    end
endmodule

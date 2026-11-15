// HUD：在 VGA/HDMI 上顯示分數、等級、下一塊預覽（8×8 字型）
module hud (
    input  pclk,
    input  [9:0]  hcnt, vcnt,   // 像素座標
    input  [15:0] score,
    input  [2:0]  level,
    input  [2:0]  next_type,
    output        hud_on        // 1 = 畫白點
);
    // ---- 8x8 字型（0-9 與部分字母）----
    function [7:0] glyph;
        input [7:0] ch; input [2:0] r;
        reg [7:0] g;
        begin
            case (ch)
                "0": case (r) 0:g=8'h3C;1:g=8'h66;2:g=8'h6E;3:g=8'h76;4:g=8'h66;5:g=8'h66;6:g=8'h3C;7:g=8'h00;default:g=8'h00; endcase
                "1": case (r) 0:g=8'h18;1:g=8'h38;2:g=8'h18;3:g=8'h18;4:g=8'h18;5:g=8'h18;6:g=8'h7E;7:g=8'h00;default:g=8'h00; endcase
                "2": case (r) 0:g=8'h3C;1:g=8'h66;2:g=8'h06;3:g=8'h0C;4:g=8'h30;5:g=8'h60;6:g=8'h7E;7:g=8'h00;default:g=8'h00; endcase
                "3": case (r) 0:g=8'h3C;1:g=8'h66;2:g=8'h06;3:g=8'h1C;4:g=8'h06;5:g=8'h66;6:g=8'h3C;7:g=8'h00;default:g=8'h00; endcase
                "4": case (r) 0:g=8'h0C;1:g=8'h1C;2:g=8'h3C;3:g=8'h6C;4:g=8'h7E;5:g=8'h0C;6:g=8'h0C;7:g=8'h00;default:g=8'h00; endcase
                "5": case (r) 0:g=8'h7E;1:g=8'h60;2:g=8'h7C;3:g=8'h06;4:g=8'h06;5:g=8'h66;6:g=8'h3C;7:g=8'h00;default:g=8'h00; endcase
                "6": case (r) 0:g=8'h3C;1:g=8'h60;2:g=8'h7C;3:g=8'h66;4:g=8'h66;5:g=8'h66;6:g=8'h3C;7:g=8'h00;default:g=8'h00; endcase
                "7": case (r) 0:g=8'h7E;1:g=8'h66;2:g=8'h0C;3:g=8'h18;4:g=8'h18;5:g=8'h18;6:g=8'h18;7:g=8'h00;default:g=8'h00; endcase
                "8": case (r) 0:g=8'h3C;1:g=8'h66;2:g=8'h66;3:g=8'h3C;4:g=8'h66;5:g=8'h66;6:g=8'h3C;7:g=8'h00;default:g=8'h00; endcase
                "9": case (r) 0:g=8'h3C;1:g=8'h66;2:g=8'h66;3:g=8'h3E;4:g=8'h06;5:g=8'h0C;6:g=8'h38;7:g=8'h00;default:g=8'h00; endcase
                "S": case (r) 0:g=8'h3C;1:g=8'h66;2:g=8'h60;3:g=8'h3C;4:g=8'h06;5:g=8'h66;6:g=8'h3C;7:g=8'h00;default:g=8'h00; endcase
                "C": case (r) 0:g=8'h3C;1:g=8'h66;2:g=8'h60;3:g=8'h60;4:g=8'h60;5:g=8'h66;6:g=8'h3C;7:g=8'h00;default:g=8'h00; endcase
                "O": case (r) 0:g=8'h3C;1:g=8'h66;2:g=8'h66;3:g=8'h66;4:g=8'h66;5:g=8'h66;6:g=8'h3C;7:g=8'h00;default:g=8'h00; endcase
                "R": case (r) 0:g=8'h7C;1:g=8'h66;2:g=8'h66;3:g=8'h7C;4:g=8'h78;5:g=8'h6C;6:g=8'h66;7:g=8'h00;default:g=8'h00; endcase
                "E": case (r) 0:g=8'h7E;1:g=8'h60;2:g=8'h60;3:g=8'h7C;4:g=8'h60;5:g=8'h60;6:g=8'h7E;7:g=8'h00;default:g=8'h00; endcase
                "L": case (r) 0:g=8'h60;1:g=8'h60;2:g=8'h60;3:g=8'h60;4:g=8'h60;5:g=8'h60;6:g=8'h7E;7:g=8'h00;default:g=8'h00; endcase
                "V": case (r) 0:g=8'h66;1:g=8'h66;2:g=8'h66;3:g=8'h66;4:g=8'h66;5:g=8'h3C;6:g=8'h18;7:g=8'h00;default:g=8'h00; endcase
                "N": case (r) 0:g=8'h66;1:g=8'h76;2:g=8'h7E;3:g=8'h7E;4:g=8'h6E;5:g=8'h66;6:g=8'h66;7:g=8'h00;default:g=8'h00; endcase
                "X": case (r) 0:g=8'h66;1:g=8'h66;2:g=8'h3C;3:g=8'h18;4:g=8'h3C;5:g=8'h66;6:g=8'h66;7:g=8'h00;default:g=8'h00; endcase
                "T": case (r) 0:g=8'h7E;1:g=8'h18;2:g=8'h18;3:g=8'h18;4:g=8'h18;5:g=8'h18;6:g=8'h18;7:g=8'h00;default:g=8'h00; endcase
                default: g = 8'h00;
            endcase
            glyph = g;
        end
    endfunction

    // ---- 在 (dx,dy) 畫字元 ch：像素 (hcnt,vcnt) 是否命中 ----
    function char_hit;
        input [7:0] ch; input [9:0] dx; input [9:0] dy;
        reg [9:0] cx, cy;
        begin
            cx = hcnt - dx; cy = vcnt - dy;
            if (cx < 10'd8 && cy < 10'd8)
                char_hit = (glyph(ch, cy[2:0]) & (8'h80 >> cx[2:0])) != 0;
            else
                char_hit = 1'b0;
        end
    endfunction

    // ---- 分數轉 5 位十進位（打拍暫存，減輕時序）----
    wire [3:0] d0 = score % 10;
    wire [3:0] d1 = (score / 10) % 10;
    wire [3:0] d2 = (score / 100) % 10;
    wire [3:0] d3 = (score / 1000) % 10;
    wire [3:0] d4 = (score / 10000) % 10;
    reg [3:0] d0_r = 0, d1_r = 0, d2_r = 0, d3_r = 0, d4_r = 0;
    always @(posedge pclk) begin
        d0_r <= d0; d1_r <= d1; d2_r <= d2; d3_r <= d3; d4_r <= d4;
    end

    function [7:0] dig_ascii;
        input [3:0] d;
        begin
            dig_ascii = "0" + d;
        end
    endfunction

    // ---- 下一塊的 4x4 位元圖（spawn 方向）----
    function [15:0] next_bitmap;
        input [2:0] t;
        begin
            case (t)
                3'd0: next_bitmap = 16'h0F00;  // I
                3'd1: next_bitmap = 16'h0660;  // O
                3'd2: next_bitmap = 16'h0E40;  // T
                3'd3: next_bitmap = 16'h06C0;  // S
                3'd4: next_bitmap = 16'h0C60;  // Z
                3'd5: next_bitmap = 16'h08E0;  // J
                default: next_bitmap = 16'h02E0; // L
            endcase
        end
    endfunction

    // ---- 版面配置（右側）----
    // 分數 5 位數在 (420, 100)，等級 1 位數在 (420, 120)，下一塊預覽在 (420, 180)
    wire score_digits = char_hit(dig_ascii(d4_r),10'd420,10'd100) ||
                        char_hit(dig_ascii(d3_r),10'd428,10'd100) ||
                        char_hit(dig_ascii(d2_r),10'd436,10'd100) ||
                        char_hit(dig_ascii(d1_r),10'd444,10'd100) ||
                        char_hit(dig_ascii(d0_r),10'd452,10'd100);
    wire level_digit  = char_hit(dig_ascii({1'b0, level}),10'd420,10'd120);

    // 下一塊預覽：4x4 格，每格 16x16 px，原點 (420, 180) → 64x64
    wire in_next = (hcnt >= 10'd420) && (hcnt < 10'd484) && (vcnt >= 10'd180) && (vcnt < 10'd244);
    wire [1:0] ncol = (hcnt - 10'd420) >> 4;
    wire [1:0] nrow = (vcnt - 10'd180) >> 4;
    wire [15:0] nbm = next_bitmap(next_type);
    wire next_cell = in_next && nbm[{nrow, ncol}];

    // 打一拍暫存（隔離組合邏輯，減輕時序）
    reg hud_on_r = 0;
    always @(posedge pclk)
        hud_on_r <= score_digits || level_digit || next_cell;
    assign hud_on = hud_on_r;
endmodule

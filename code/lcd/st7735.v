// WiFiBoy 內建 LCD（ST7735，SPI，128x160）驅動（含文字繪製）
// 功能：初始化 → 填黑 → 畫選單文字 → 保持顯示
// SPI：mode 0，1.5MHz（8 clk/bit）——實測 6MHz 會失敗
//
// 接腳極性（依 C 驅動）：DC 0=命令 1=資料；NRST 0=復位 1=正常；BL 0=開 1=關
module st7735 (
    input  clk12,
    input  selected,      // 0=VGA, 1=HDMI（指標位置）
    input  redraw,        // 脈衝：重畫選單
    output lcd_sclk, lcd_mosi, lcd_cs, lcd_dc, lcd_rst, lcd_bl
);

    reg sclk_r = 0;
    reg mosi_r = 0;
    reg cs_r   = 1;
    reg dc_r   = 0;
    reg rst_r  = 0;
    reg bl_r   = 1;

    assign lcd_sclk = sclk_r;
    assign lcd_mosi = mosi_r;
    assign lcd_cs   = cs_r;
    assign lcd_dc   = dc_r;
    assign lcd_rst  = rst_r;
    assign lcd_bl   = bl_r;

    // ============ SPI 位元組傳送（1.5MHz）============
    reg        spi_go  = 0;
    reg        spi_busy = 0;
    reg [7:0]  spi_byte = 0;
    reg        spi_dc  = 0;
    reg [5:0]  spicnt  = 0;   // 0..63（8 clk/bit）
    reg [7:0]  spishift;

    always @(posedge clk12) begin
        if (spi_go && !spi_busy) begin
            spi_busy <= 1;
            spicnt   <= 0;
            spishift <= spi_byte;
            dc_r     <= spi_dc;
            cs_r     <= 0;
            sclk_r   <= 0;
            mosi_r   <= spi_byte[7];
        end else if (spi_busy) begin
            case (spicnt[2:0])
                3'd0: begin sclk_r <= 0; mosi_r <= spishift[7]; spicnt <= spicnt + 1; end
                3'd4: begin sclk_r <= 1; spicnt <= spicnt + 1; end
                3'd7: begin
                    if (spicnt[5:3] == 3'd7) begin
                        spi_busy <= 0;
                        cs_r     <= 1;
                        sclk_r   <= 0;
                    end else begin
                        spishift <= {spishift[6:0], 1'b0};
                        spicnt   <= spicnt + 1;
                    end
                end
                default: spicnt <= spicnt + 1;
            endcase
        end
    end

    // ============ 初始化序列 ROM ============
    reg [9:0] init_rom [0:79];
    initial begin
        init_rom[0]  = 10'b01_00000001; init_rom[1]  = 10'b10_00000000;
        init_rom[2]  = 10'b01_00010001; init_rom[3]  = 10'b10_00000000;
        init_rom[4]  = 10'b01_10110001;
        init_rom[5]  = 10'b00_00000101; init_rom[6]  = 10'b00_00111100; init_rom[7]  = 10'b00_00111100;
        init_rom[8]  = 10'b01_10110010;
        init_rom[9]  = 10'b00_00000101; init_rom[10] = 10'b00_00111100; init_rom[11] = 10'b00_00111100;
        init_rom[12] = 10'b01_10110011;
        init_rom[13] = 10'b00_00000101; init_rom[14] = 10'b00_00111100; init_rom[15] = 10'b00_00111100;
        init_rom[16] = 10'b00_00000101; init_rom[17] = 10'b00_00111100; init_rom[18] = 10'b00_00111100;
        init_rom[19] = 10'b01_10110100; init_rom[20] = 10'b00_00000011;
        init_rom[21] = 10'b01_11000000;
        init_rom[22] = 10'b00_00101000; init_rom[23] = 10'b00_00001000; init_rom[24] = 10'b00_00000100;
        init_rom[25] = 10'b01_11000001; init_rom[26] = 10'b00_11000000;
        init_rom[27] = 10'b01_11000010; init_rom[28] = 10'b00_00001101; init_rom[29] = 10'b00_00000000;
        init_rom[30] = 10'b01_11000011; init_rom[31] = 10'b00_10001101; init_rom[32] = 10'b00_00101010;
        init_rom[33] = 10'b01_11000100; init_rom[34] = 10'b00_10001101; init_rom[35] = 10'b00_11101110;
        init_rom[36] = 10'b01_11000101; init_rom[37] = 10'b00_00011010;
        init_rom[38] = 10'b01_00110110; init_rom[39] = 10'b00_10100000;
        init_rom[40] = 10'b01_00111010; init_rom[41] = 10'b00_00000101;
        init_rom[42] = 10'b01_11100000;
        init_rom[43] = 10'b00_00000100; init_rom[44] = 10'b00_00100010; init_rom[45] = 10'b00_00000111;
        init_rom[46] = 10'b00_00001010; init_rom[47] = 10'b00_00101110; init_rom[48] = 10'b00_00110000;
        init_rom[49] = 10'b00_00100101; init_rom[50] = 10'b00_00101010; init_rom[51] = 10'b00_00101000;
        init_rom[52] = 10'b00_00100110; init_rom[53] = 10'b00_00101110; init_rom[54] = 10'b00_00111010;
        init_rom[55] = 10'b00_00000000; init_rom[56] = 10'b00_00000001; init_rom[57] = 10'b00_00000011;
        init_rom[58] = 10'b00_00010011;
        init_rom[59] = 10'b01_11100001;
        init_rom[60] = 10'b00_00000100; init_rom[61] = 10'b00_00010110; init_rom[62] = 10'b00_00000110;
        init_rom[63] = 10'b00_00001101; init_rom[64] = 10'b00_00101101; init_rom[65] = 10'b00_00100110;
        init_rom[66] = 10'b00_00100011; init_rom[67] = 10'b00_00100111; init_rom[68] = 10'b00_00100111;
        init_rom[69] = 10'b00_00100101; init_rom[70] = 10'b00_00101101; init_rom[71] = 10'b00_00111011;
        init_rom[72] = 10'b00_00000000; init_rom[73] = 10'b00_00000001; init_rom[74] = 10'b00_00000100;
        init_rom[75] = 10'b00_00010011;
        init_rom[76] = 10'b01_00101001; init_rom[77] = 10'b10_00000000;
        init_rom[78] = 10'b11_00000000; init_rom[79] = 10'b11_00000000;
    end

    // ============ 8x8 字型（僅選單需要的字元）============
    function [7:0] glyph;
        input [7:0] ch;
        input [2:0] r;
        reg [7:0] g;
        begin
            case (ch)
                " ": g = 8'h00;
                ">": begin
                    case (r) 0: g = 8'h60; 1: g = 8'h30; 2: g = 8'h18; 3: g = 8'h0C; 4: g = 8'h18; 5: g = 8'h30; 6: g = 8'h60; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "A": begin
                    case (r) 0: g = 8'h3C; 1: g = 8'h66; 2: g = 8'h66; 3: g = 8'h7E; 4: g = 8'h66; 5: g = 8'h66; 6: g = 8'h66; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "C": begin
                    case (r) 0: g = 8'h3C; 1: g = 8'h66; 2: g = 8'h60; 3: g = 8'h60; 4: g = 8'h60; 5: g = 8'h66; 6: g = 8'h3C; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "D": begin
                    case (r) 0: g = 8'h78; 1: g = 8'h6C; 2: g = 8'h66; 3: g = 8'h66; 4: g = 8'h66; 5: g = 8'h6C; 6: g = 8'h78; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "E": begin
                    case (r) 0: g = 8'h7E; 1: g = 8'h60; 2: g = 8'h60; 3: g = 8'h7C; 4: g = 8'h60; 5: g = 8'h60; 6: g = 8'h7E; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "G": begin
                    case (r) 0: g = 8'h3C; 1: g = 8'h66; 2: g = 8'h60; 3: g = 8'h6E; 4: g = 8'h66; 5: g = 8'h66; 6: g = 8'h3C; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "H": begin
                    case (r) 0: g = 8'h66; 1: g = 8'h66; 2: g = 8'h66; 3: g = 8'h7E; 4: g = 8'h66; 5: g = 8'h66; 6: g = 8'h66; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "I": begin
                    case (r) 0: g = 8'h7E; 1: g = 8'h18; 2: g = 8'h18; 3: g = 8'h18; 4: g = 8'h18; 5: g = 8'h18; 6: g = 8'h7E; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "L": begin
                    case (r) 0: g = 8'h60; 1: g = 8'h60; 2: g = 8'h60; 3: g = 8'h60; 4: g = 8'h60; 5: g = 8'h60; 6: g = 8'h7E; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "M": begin
                    case (r) 0: g = 8'h63; 1: g = 8'h77; 2: g = 8'h7F; 3: g = 8'h6B; 4: g = 8'h63; 5: g = 8'h63; 6: g = 8'h63; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "O": begin
                    case (r) 0: g = 8'h3C; 1: g = 8'h66; 2: g = 8'h66; 3: g = 8'h66; 4: g = 8'h66; 5: g = 8'h66; 6: g = 8'h3C; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "P": begin
                    case (r) 0: g = 8'h7C; 1: g = 8'h66; 2: g = 8'h66; 3: g = 8'h7C; 4: g = 8'h60; 5: g = 8'h60; 6: g = 8'h60; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "S": begin
                    case (r) 0: g = 8'h3C; 1: g = 8'h66; 2: g = 8'h60; 3: g = 8'h3C; 4: g = 8'h06; 5: g = 8'h66; 6: g = 8'h3C; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "T": begin
                    case (r) 0: g = 8'h7E; 1: g = 8'h18; 2: g = 8'h18; 3: g = 8'h18; 4: g = 8'h18; 5: g = 8'h18; 6: g = 8'h18; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "U": begin
                    case (r) 0: g = 8'h66; 1: g = 8'h66; 2: g = 8'h66; 3: g = 8'h66; 4: g = 8'h66; 5: g = 8'h66; 6: g = 8'h3C; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                "V": begin
                    case (r) 0: g = 8'h66; 1: g = 8'h66; 2: g = 8'h66; 3: g = 8'h66; 4: g = 8'h66; 5: g = 8'h3C; 6: g = 8'h18; 7: g = 8'h00; default: g = 8'h00; endcase
                end
                default: g = 8'h00;
            endcase
            glyph = g;
        end
    endfunction

    // ============ 選單文字 ROM（0x0A=換行, 0x00=結束）============
    reg [7:0] text_rom [0:27];
    initial begin
        // "SELECT OUTPUT"
        text_rom[0]="S"; text_rom[1]="E"; text_rom[2]="L"; text_rom[3]="E";
        text_rom[4]="C"; text_rom[5]="T"; text_rom[6]=" "; text_rom[7]="O";
        text_rom[8]="U"; text_rom[9]="T"; text_rom[10]="P"; text_rom[11]="U"; text_rom[12]="T";
        text_rom[13]=8'h0A;
        // "> VGA"
        text_rom[14]=8'h01; text_rom[15]=" "; text_rom[16]="V"; text_rom[17]="G"; text_rom[18]="A";
        text_rom[19]=8'h0A;
        // "  HDMI"
        text_rom[20]=8'h01; text_rom[21]=" "; text_rom[22]="H"; text_rom[23]="D";
        text_rom[24]="M"; text_rom[25]="I";
        text_rom[26]=8'h00; text_rom[27]=8'h00;
    end

    // ============ 主狀態機 ============
    localparam S_RESET = 3'd0, S_INIT = 3'd1, S_DELAY = 3'd2,
               S_FILL = 3'd3, S_DRAW = 3'd4, S_WAIT = 3'd5, S_POINTER = 3'd6;
    reg [2:0] state = S_RESET;
    reg rst_phase = 0;
    reg send_pending = 0;
    reg [20:0] wait_cnt = 0;
    reg [6:0]  init_idx = 0;

    // fill 計數器
    reg [7:0]  fx = 0, fy = 0;
    reg [3:0]  fstep = 0;
    reg        fhi = 0;

    // draw 計數器
    reg [7:0]  dx = 0, dy = 0;   // 目前字元位置
    reg [2:0]  drow = 0;         // 0..7
    reg [2:0]  dcol = 0;         // 0..7
    reg [4:0]  dstep = 0;        // 0..10 視窗, 11+ 像素
    reg        dhi = 0;          // 像素 hi/lo
    reg [7:0]  dchar = 0;        // 目前字元
    reg [5:0]  tchar = 0;        // 文字索引
    reg        pidx = 0;         // 指標重畫：0=VGA, 1=HDMI

    always @(posedge clk12) begin
        spi_go <= 0;
        if (send_pending && spi_busy) send_pending <= 0;

        case (state)
            S_RESET: begin
                if (!rst_phase) begin
                    rst_r <= 0;
                    if (wait_cnt == 21'd600000) begin
                        wait_cnt <= 0; rst_r <= 1; rst_phase <= 1;
                    end else wait_cnt <= wait_cnt + 1;
                end else begin
                    rst_r <= 1;
                    if (wait_cnt == 21'd600000) begin
                        wait_cnt <= 0; state <= S_INIT;
                    end else wait_cnt <= wait_cnt + 1;
                end
            end

            S_INIT: begin
                if (!send_pending && !spi_busy) begin
                    case (init_rom[init_idx][9:8])
                        2'b01: begin spi_byte <= init_rom[init_idx][7:0]; spi_dc <= 0; spi_go <= 1; send_pending <= 1; init_idx <= init_idx + 1; end
                        2'b00: begin spi_byte <= init_rom[init_idx][7:0]; spi_dc <= 1; spi_go <= 1; send_pending <= 1; init_idx <= init_idx + 1; end
                        2'b10: begin init_idx <= init_idx + 1; wait_cnt <= 0; state <= S_DELAY; end
                        default: begin bl_r <= 0; state <= S_FILL; fstep <= 0; fx <= 0; fy <= 0; fhi <= 0; end
                    endcase
                end
            end

            S_DELAY: begin
                if (wait_cnt == 21'd1440000) state <= S_INIT;
                else wait_cnt <= wait_cnt + 1;
            end

            S_FILL: begin
                if (!send_pending && !spi_busy) begin
                    case (fstep)
                        0: begin spi_byte <= 8'h2A; spi_dc <= 0; spi_go <= 1; send_pending <= 1; fstep <= 1; end
                        1: begin spi_byte <= 8'h00; spi_dc <= 1; spi_go <= 1; send_pending <= 1; fstep <= 2; end
                        2: begin spi_byte <= 8'h01; spi_dc <= 1; spi_go <= 1; send_pending <= 1; fstep <= 3; end
                        3: begin spi_byte <= 8'h00; spi_dc <= 1; spi_go <= 1; send_pending <= 1; fstep <= 4; end
                        4: begin spi_byte <= 8'd160; spi_dc <= 1; spi_go <= 1; send_pending <= 1; fstep <= 5; end
                        5: begin spi_byte <= 8'h2B; spi_dc <= 0; spi_go <= 1; send_pending <= 1; fstep <= 6; end
                        6: begin spi_byte <= 8'h00; spi_dc <= 1; spi_go <= 1; send_pending <= 1; fstep <= 7; end
                        7: begin spi_byte <= 8'h02; spi_dc <= 1; spi_go <= 1; send_pending <= 1; fstep <= 8; end
                        8: begin spi_byte <= 8'h00; spi_dc <= 1; spi_go <= 1; send_pending <= 1; fstep <= 9; end
                        9: begin spi_byte <= 8'd129; spi_dc <= 1; spi_go <= 1; send_pending <= 1; fstep <= 10; end
                        10: begin spi_byte <= 8'h2C; spi_dc <= 0; spi_go <= 1; send_pending <= 1; fstep <= 11; end
                        default: begin
                            spi_dc <= 1; spi_go <= 1; send_pending <= 1;
                            spi_byte <= 8'h00;   // 填黑
                            if (!fhi) fhi <= 1;
                            else begin
                                fhi <= 0;
                                if (fx == 8'd159) begin
                                    fx <= 0;
                                    if (fy == 8'd127) begin
                                        state <= S_DRAW;
                                        tchar <= 0; dx <= 8; dy <= 20;
                                        dstep <= 0; dhi <= 0;
                                    end else fy <= fy + 1;
                                end else fx <= fx + 1;
                            end
                        end
                    endcase
                end
            end

            S_DRAW: begin
                if (!send_pending && !spi_busy) begin
                    case (dstep)
                        // 0: 讀下一個字元（處理換行/結束）
                        0: begin
                            case (text_rom[tchar])
                                8'h00: state <= S_WAIT;
                                8'h0A: begin dx <= 8'd8; dy <= dy + 8'd12; tchar <= tchar + 1; end
                                8'h01: begin  // 指標：依 selected 決定 '>' 或 ' '
                                    if ((tchar == 6'd14 && selected == 1'b0) ||
                                        (tchar == 6'd20 && selected == 1'b1))
                                        dchar <= ">";
                                    else
                                        dchar <= " ";
                                    tchar <= tchar + 1; dstep <= 1; drow <= 0; dcol <= 0; dhi <= 0;
                                end
                                default: begin dchar <= text_rom[tchar]; tchar <= tchar + 1; dstep <= 1; drow <= 0; dcol <= 0; dhi <= 0; end
                            endcase
                        end
                        // 1..11: 設視窗（CASET/RASET/RAMWR）
                        1: begin spi_byte <= 8'h2A; spi_dc <= 0; spi_go <= 1; send_pending <= 1; dstep <= 2; end
                        2: begin spi_byte <= 8'h00; spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 3; end
                        3: begin spi_byte <= (dx + 8'd1); spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 4; end
                        4: begin spi_byte <= 8'h00; spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 5; end
                        5: begin spi_byte <= (dx + 8'd8); spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 6; end
                        6: begin spi_byte <= 8'h2B; spi_dc <= 0; spi_go <= 1; send_pending <= 1; dstep <= 7; end
                        7: begin spi_byte <= 8'h00; spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 8; end
                        8: begin spi_byte <= (dy + 8'd2); spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 9; end
                        9: begin spi_byte <= 8'h00; spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 10; end
                        10: begin spi_byte <= (dy + 8'd9); spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 11; end
                        11: begin spi_byte <= 8'h2C; spi_dc <= 0; spi_go <= 1; send_pending <= 1; dstep <= 12; end
                        // 12+: 64 像素
                        default: begin
                            spi_dc <= 1; spi_go <= 1; send_pending <= 1;
                            if (glyph(dchar, drow) & (8'h80 >> dcol))
                                spi_byte <= 8'hFF;   // 白
                            else
                                spi_byte <= 8'h00;   // 黑
                            if (!dhi) begin
                                dhi <= 1;
                            end else begin
                                dhi <= 0;
                                if (dcol == 3'd7) begin
                                    dcol <= 0;
                                    if (drow == 3'd7) begin
                                        // 字元畫完 → 下一個
                                        drow <= 0;
                                        dstep <= 0;
                                        dx <= dx + 8'd8;
                                    end else drow <= drow + 1;
                                end else dcol <= dcol + 1;
                            end
                        end
                    endcase
                end
            end

            S_POINTER: begin
                if (!send_pending && !spi_busy) begin
                    case (dstep)
                        0: begin  // 載入指標字元（VGA@(8,32)、HDMI@(8,44)）
                            if (pidx == 0)
                                dchar <= (selected == 0) ? ">" : " ";
                            else
                                dchar <= (selected == 1) ? ">" : " ";
                            drow <= 0; dcol <= 0; dhi <= 0;
                            dstep <= 1;
                        end
                        1: begin spi_byte <= 8'h2A; spi_dc <= 0; spi_go <= 1; send_pending <= 1; dstep <= 2; end
                        2: begin spi_byte <= 8'h00; spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 3; end
                        3: begin spi_byte <= 8'd9;  spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 4; end
                        4: begin spi_byte <= 8'h00; spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 5; end
                        5: begin spi_byte <= 8'd16; spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 6; end
                        6: begin spi_byte <= 8'h2B; spi_dc <= 0; spi_go <= 1; send_pending <= 1; dstep <= 7; end
                        7: begin spi_byte <= 8'h00; spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 8; end
                        8: begin spi_byte <= (pidx == 0 ? 8'd34 : 8'd46); spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 9; end
                        9: begin spi_byte <= 8'h00; spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 10; end
                        10: begin spi_byte <= (pidx == 0 ? 8'd41 : 8'd53); spi_dc <= 1; spi_go <= 1; send_pending <= 1; dstep <= 11; end
                        11: begin spi_byte <= 8'h2C; spi_dc <= 0; spi_go <= 1; send_pending <= 1; dstep <= 12; end
                        default: begin  // 64 像素
                            spi_dc <= 1; spi_go <= 1; send_pending <= 1;
                            if (glyph(dchar, drow) & (8'h80 >> dcol))
                                spi_byte <= 8'hFF;
                            else
                                spi_byte <= 8'h00;
                            if (!dhi) begin
                                dhi <= 1;
                            end else begin
                                dhi <= 0;
                                if (dcol == 3'd7) begin
                                    dcol <= 0;
                                    if (drow == 3'd7) begin
                                        drow <= 0;
                                        if (pidx == 0) begin
                                            pidx <= 1; dstep <= 0;  // 畫第二個指標
                                        end else begin
                                            state <= S_WAIT;  // 完成
                                        end
                                    end else drow <= drow + 1;
                                end else dcol <= dcol + 1;
                            end
                        end
                    endcase
                end
            end

            S_WAIT: begin
                if (redraw) begin
                    state <= S_POINTER;
                    pidx <= 0; dstep <= 0;
                end
            end
        endcase
    end

endmodule

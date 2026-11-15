// WiFiBoy 俄羅斯方塊（開發中）：LCD 選單 + VGA/HDMI 棋盤渲染
// 選 VGA → VGA 顯示棋盤；選 HDMI → HDMI 顯示棋盤
module tetris (
    input  clk12,
    input  key_u, key_d, key_l, key_r, key_a, key_b, key_m,
    output led_b, led_r,
    // LCD
    output lcd_sclk, lcd_mosi, lcd_cs, lcd_dc, lcd_rst, lcd_bl,
    // PMOD 共享腳位（VGA / HDMI 二選一）
    output r1, r0, g1, g0, b1,      // 42-46（兩者同）
    output p6, p7,                  // 47:VGA-B0/HDMI-CL, 48:VGA-VS/HDMI-DE
    output hs,                      // 2（兩者同）
    output p9,                      // 3:VGA-Snd/HDMI-VS
    output speaker                  // 音效（pin 10）
);
    // PLL：12MHz -> 25.125MHz
    wire pclk, locked;
    pll pll_i(.clock_in(clk12), .clock_out(pclk), .locked(locked));

    // 去彈跳（本板按鍵為 active-LOW：按下=0，放開=1 → 反相後給 debounce）
    wire u_press, d_press, l_press, r_press, a_press, b_press, m_press;
    wire d_held;
    debounce db_u(.clk(pclk), .btn_in(~key_u), .btn_press(u_press));
    debounce db_d(.clk(pclk), .btn_in(~key_d), .btn_out(d_held), .btn_press(d_press));
    debounce db_l(.clk(pclk), .btn_in(~key_l), .btn_press(l_press));
    debounce db_r(.clk(pclk), .btn_in(~key_r), .btn_press(r_press));
    debounce db_a(.clk(pclk), .btn_in(~key_a), .btn_press(a_press));
    debounce db_b(.clk(pclk), .btn_in(~key_b), .btn_press(b_press));
    debounce db_m(.clk(pclk), .btn_in(~key_m), .btn_press(m_press));

    // 開機空白期：前 ~500ms 忽略按鍵
    reg [23:0] startup_cnt = 0;
    wire startup_done = (startup_cnt >= 24'd12562500);
    always @(posedge pclk) begin
        if (!startup_done) startup_cnt <= startup_cnt + 1;
    end
    wire u_p = u_press && startup_done;
    wire d_p = d_press && startup_done;
    wire a_p = a_press && startup_done;
    wire l_p = l_press && startup_done;
    wire r_p = r_press && startup_done;
    wire b_p = b_press && startup_done;
    wire m_p = m_press && startup_done;

    // 選單邏輯
    reg [1:0] selected = 0;   // 0=VGA, 1=HDMI, 2=LCD
    reg vga_on  = 0;
    reg hdmi_on = 0;
    reg lcd_on  = 0;
    reg redraw  = 0;
    wire game_start = vga_on || hdmi_on || lcd_on;   // 選單選完 = 遊戲開始
    always @(posedge pclk) begin
        redraw <= 0;
        if (!game_start) begin
            if (u_p && selected != 2'd0) begin
                selected <= selected - 2'd1; redraw <= 1;
            end else if (d_p && selected != 2'd2) begin
                selected <= selected + 2'd1; redraw <= 1;
            end else if (a_p) begin
                case (selected)
                    2'd0: vga_on  <= 1;
                    2'd1: hdmi_on <= 1;
                    2'd2: lcd_on  <= 1;
                endcase
            end
        end
    end
    assign led_b = vga_on;    // 紅燈 = VGA
    assign led_r = hdmi_on;   // 藍燈 = HDMI

    // 視訊時序（共享）
    wire [9:0] hcnt, vcnt;
    wire vhs, vvs, vde;
    video_timing vt(
        .pclk(pclk), .hcnt(hcnt), .vcnt(vcnt),
        .hs(vhs), .vs(vvs), .de(vde)
    );

    // 棋盤 BRAM
    wire [15:0] bram_rdata;
    wire [4:0]  bram_raddr, bram_waddr;
    wire [15:0] bram_wdata;
    wire        bram_we;
    board_ram bram(
        .clk(pclk),
        .raddr(bram_raddr), .waddr(bram_waddr),
        .wdata(bram_wdata), .we(bram_we),
        .rdata(bram_rdata)
    );

    // 遊戲邏輯（選單選完後開始）
    wire game_over;
    wire [4:0] g_raddr, g_waddr;
    wire [15:0] g_wdata;
    wire g_read, g_we;
    wire signed [4:0] piece_x;
    wire [4:0] piece_y;
    wire [1:0] piece_rot;
    wire [2:0] piece_type;
    wire piece_active;
    wire [15:0] score;
    wire [2:0]  level;
    wire [8:0]  lines;
    wire [2:0]  next_type;
    wire snd_lock, snd_clear;
    game game_i(
        .clk(pclk), .start(game_start),
        .move_left(l_p), .move_right(r_p),
        .rotate_cw(u_p), .rotate_ccw(b_p),
        .soft_drop(d_p), .soft_held(d_held),
        .hard_drop(a_p), .restart(m_p),
        .bram_rdata(bram_rdata),
        .g_raddr(g_raddr), .g_read(g_read),
        .g_waddr(g_waddr), .g_wdata(g_wdata), .g_we(g_we),
        .piece_x(piece_x), .piece_y(piece_y), .piece_rot(piece_rot),
        .piece_type(piece_type), .piece_active(piece_active),
        .score(score), .level(level), .lines(lines), .next_type(next_type),
        .game_over(game_over), .snd_lock(snd_lock), .snd_clear(snd_clear)
    );

    // 音效
    sound snd(
        .clk(pclk),
        .move_s(l_p || r_p), .rotate_s(u_p || b_p),
        .lock_s(snd_lock), .clear_s(snd_clear),
        .over_s(game_over),
        .speaker(speaker)
    );

    // 棋盤渲染
    wire [5:0] board_rgb;
    wire [4:0] renderer_raddr;
    board_render br(
        .pclk(pclk), .hcnt(hcnt), .vcnt(vcnt),
        .bram_rdata(bram_rdata),
        .piece_x(piece_x), .piece_y(piece_y), .piece_rot(piece_rot),
        .piece_type(piece_type), .piece_active(piece_active),
        .renderer_raddr(renderer_raddr), .rgb(board_rgb)
    );

    // HUD（分數/等級/下一塊）
    wire hud_on;
    hud hd(
        .pclk(pclk), .hcnt(hcnt), .vcnt(vcnt),
        .score(score), .level(level), .next_type(next_type),
        .hud_on(hud_on)
    );

    // HUD 白字覆蓋棋盤
    wire [5:0] rgb = (hud_on && game_start) ? 6'b111111 : board_rgb;

    // LCD（選單 + 遊戲渲染）
    wire [4:0] lcd_raddr;
    st7735 lcd(
        .clk12(pclk), .selected(selected), .redraw(redraw),
        .game_en(lcd_on), .bram_rdata(bram_rdata),
        .piece_x(piece_x), .piece_y(piece_y), .piece_rot(piece_rot),
        .piece_type(piece_type), .piece_active(piece_active),
        .score(score), .level(level), .next_type(next_type),
        .lcd_raddr(lcd_raddr),
        .lcd_sclk(lcd_sclk), .lcd_mosi(lcd_mosi), .lcd_cs(lcd_cs),
        .lcd_dc(lcd_dc), .lcd_rst(lcd_rst), .lcd_bl(lcd_bl)
    );

    // BRAM 讀位址多工：遊戲邏輯（檢查時）優先，否則 LCD（若選 LCD）或渲染器
    assign bram_raddr = g_read ? g_raddr : (lcd_on ? lcd_raddr : renderer_raddr);
    assign bram_waddr = g_waddr;
    assign bram_wdata = g_wdata;
    assign bram_we    = g_we;

    // VGA 輸出
    wire vga_r0, vga_r1, vga_g0, vga_g1, vga_b0, vga_b1, vga_hs, vga_vs, vga_snd;
    vga vga_i(
        .pclk(pclk), .enable(vga_on), .rgb(rgb), .hs(vhs), .vs(vvs),
        .r0(vga_r0), .r1(vga_r1), .g0(vga_g0), .g1(vga_g1), .b0(vga_b0), .b1(vga_b1),
        .vga_hs(vga_hs), .vga_vs(vga_vs), .snd(vga_snd)
    );

    // HDMI 輸出
    wire hdmi_r0, hdmi_r1, hdmi_g0, hdmi_g1, hdmi_b1, hdmi_cl, hdmi_de, hdmi_hs, hdmi_vs;
    hdmi hdmi_i(
        .pclk(pclk), .enable(hdmi_on), .rgb(rgb), .hs(vhs), .vs(vvs), .de(vde),
        .r0(hdmi_r0), .r1(hdmi_r1), .g0(hdmi_g0), .g1(hdmi_g1), .b1(hdmi_b1),
        .cl(hdmi_cl), .hdmi_de(hdmi_de), .hdmi_hs(hdmi_hs), .hdmi_vs(hdmi_vs)
    );

    // PMOD 多工：依 vga_on 選擇 VGA 或 HDMI 訊號
    assign r1 = vga_on ? vga_r1 : hdmi_r1;
    assign r0 = vga_on ? vga_r0 : hdmi_r0;
    assign g1 = vga_on ? vga_g1 : hdmi_g1;
    assign g0 = vga_on ? vga_g0 : hdmi_g0;
    assign b1 = vga_on ? vga_b1 : hdmi_b1;
    assign p6 = vga_on ? vga_b0 : hdmi_cl;    // 47
    assign p7 = vga_on ? vga_vs : hdmi_de;    // 48
    assign hs = vga_on ? vga_hs : hdmi_hs;    // 2
    assign p9 = vga_on ? vga_snd : hdmi_vs;   // 3
endmodule

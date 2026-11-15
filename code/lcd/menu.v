// WiFiBoy 選單主控：上下鍵移動指標、A 鍵確認（VGA/HDMI），LED 顯示確認結果
module menu (
    input  clk12,
    input  key_u, key_d, key_a,
    output led_b, led_r,
    output lcd_sclk, lcd_mosi, lcd_cs, lcd_dc, lcd_rst, lcd_bl
);
    // 去彈跳
    wire u_press, d_press, a_press;
    debounce db_u(.clk(clk12), .btn_in(key_u), .btn_press(u_press));
    debounce db_d(.clk(clk12), .btn_in(key_d), .btn_press(d_press));
    debounce db_a(.clk(clk12), .btn_in(key_a), .btn_press(a_press));

    // 選單邏輯
    reg selected  = 0;   // 0=VGA, 1=HDMI（指標位置）
    reg mode      = 0;   // 0=VGA, 1=HDMI（A 鍵確認後鎖定）
    reg confirmed = 0;   // 是否已確認
    reg redraw    = 0;

    always @(posedge clk12) begin
        redraw <= 0;
        if (u_press && selected == 1) begin
            selected <= 0;
            redraw <= 1;
        end else if (d_press && selected == 0) begin
            selected <= 1;
            redraw <= 1;
        end else if (a_press) begin
            mode <= selected;
            confirmed <= 1;
        end
    end

    // LED 顯示確認的模式（確認前都滅）
    assign led_b = confirmed ? (mode == 1'b0) : 1'b0;   // 藍燈 = VGA
    assign led_r = confirmed ? (mode == 1'b1) : 1'b0;   // 紅燈 = HDMI

    // LCD
    st7735 lcd(
        .clk12(clk12),
        .selected(selected),
        .redraw(redraw),
        .lcd_sclk(lcd_sclk), .lcd_mosi(lcd_mosi), .lcd_cs(lcd_cs),
        .lcd_dc(lcd_dc), .lcd_rst(lcd_rst), .lcd_bl(lcd_bl)
    );
endmodule

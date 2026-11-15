// WiFiBoy 6-bit VGA PMOD 驅動：640x480@60，2:2:2 色（R0,R1 / G0,G1 / B0,B1）
module vga (
    input  clk12,                       // 12 MHz
    output r0, r1, g0, g1, b0, b1,      // 6-bit 色（各 2 位元）
    output hs, vs,                      // 同步（active low）
    output snd                          // 音訊（暫接地）
);
    // PLL：12MHz -> 25.125MHz 像素時脈
    wire pclk, locked;
    pll pll_i(.clock_in(clk12), .clock_out(pclk), .locked(locked));

    // 水平/垂直計數器（640x480@60：800 x 525 總數）
    reg [9:0] hcnt = 0;
    reg [9:0] vcnt = 0;
    always @(posedge pclk) begin
        if (hcnt == 10'd799) begin
            hcnt <= 0;
            vcnt <= (vcnt == 10'd524) ? 10'd0 : vcnt + 1;
        end else
            hcnt <= hcnt + 1;
    end

    wire display = (hcnt < 10'd640) && (vcnt < 10'd480);
    assign hs = ~((hcnt >= 10'd656) && (hcnt < 10'd752));  // 656~751 低態同步
    assign vs = ~((vcnt >= 10'd490) && (vcnt < 10'd492));  // 490~491 低態同步

    // 測試圖樣（漸層）：R 隨水平、G 隨垂直、B 為 XOR
    wire [1:0] R = display ? hcnt[8:7] : 2'b00;
    wire [1:0] G = display ? vcnt[8:7] : 2'b00;
    wire [1:0] B = display ? (hcnt[8:7] ^ vcnt[8:7]) : 2'b00;

    assign {r1, r0} = R;
    assign {g1, g0} = G;
    assign {b1, b0} = B;

    assign snd = 1'b0;

endmodule

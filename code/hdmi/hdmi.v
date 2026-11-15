// WiFiBoy HDMI PMOD 驅動：SIL164（DVI transmitter），640x480@60，色 2:2:1（R1,R0/G1,G0/B1）
module hdmi (
    input  clk12,
    output r0, r1, g0, g1, b1,      // 色資料（2:2:1）
    output cl,                      // 像素時脈（IDCK）
    output de, hs, vs               // Data Enable + 同步
);
    wire pclk, locked;
    pll pll_i(.clock_in(clk12), .clock_out(pclk), .locked(locked));
    assign cl = pclk;

    reg [9:0] hcnt = 0;
    reg [9:0] vcnt = 0;
    // 資料在下降緣產生 → IDCK(=pclk)上升緣取樣時已穩定（避免 setup 違例）
    always @(negedge pclk) begin
        if (hcnt == 10'd799) begin
            hcnt <= 0;
            vcnt <= (vcnt == 10'd524) ? 10'd0 : vcnt + 1;
        end else
            hcnt <= hcnt + 1;
    end

    wire display = (hcnt < 10'd640) && (vcnt < 10'd480);
    assign de = display;
    assign hs = ~((hcnt >= 10'd656) && (hcnt < 10'd752));
    assign vs = ~((vcnt >= 10'd490) && (vcnt < 10'd492));

    // 測試圖樣（漸層）：R 隨水平、G 隨垂直、B 為 XOR
    wire [1:0] R = display ? hcnt[8:7] : 2'b00;
    wire [1:0] G = display ? vcnt[8:7] : 2'b00;
    wire       B = display ? (hcnt[8] ^ vcnt[8]) : 1'b0;

    assign {r1, r0} = R;
    assign {g1, g0} = G;
    assign b1 = B;
endmodule

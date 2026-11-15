// 視訊時序：640x480@60（800x525 總數），供 VGA 與 HDMI 共用
module video_timing (
    input  pclk,                        // 25.125MHz
    output reg [9:0] hcnt,              // 0..799
    output reg [9:0] vcnt,              // 0..524
    output hs, vs, de                   // 同步（active low）+ Data Enable
);
    always @(posedge pclk) begin
        if (hcnt == 10'd799) begin
            hcnt <= 0;
            vcnt <= (vcnt == 10'd524) ? 10'd0 : vcnt + 1;
        end else
            hcnt <= hcnt + 1;
    end

    assign de = (hcnt < 10'd640) && (vcnt < 10'd480);
    assign hs = ~((hcnt >= 10'd656) && (hcnt < 10'd752));  // 656~751 低態同步
    assign vs = ~((vcnt >= 10'd490) && (vcnt < 10'd492));  // 490~491 低態同步
endmodule

// step6：0~9 計數（每秒 +1），只顯示右邊一位
module count9 (
    input  clk12,
    output a, b, c, d, e, f, g,
    output dig1, dig2
);
    // 每秒 +1
    reg [3:0] units = 0;
    reg [23:0] tick = 0;
    always @(posedge clk12) begin
        if (tick == 24'd11_999_999) begin
            tick <= 0;
            units <= (units == 4'd9) ? 4'd0 : units + 1;
        end else
            tick <= tick + 1;
    end

    // 解碼 + 顯示
    wire [6:0] seg;
    seven_seg_decoder dec(.digit(units), .seg(seg));
    assign {a, b, c, d, e, f, g} = seg;

    assign dig1 = 1'b0;   // 啟用右邊一位
    assign dig2 = 1'b1;   // 關閉左邊
endmodule

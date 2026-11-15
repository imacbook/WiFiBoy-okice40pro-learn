// step1：點亮一顆紅燈
// 共陽 RGB LED：色線 0 = 亮、選線 1 = 致能
module rgb_one (
    input  clk12,
    output r, g, b,
    output d0, d1, d2, d3, d4, d5
);
    assign r  = 1'b0;   // 紅 ON
    assign g  = 1'b1;   // 綠 OFF
    assign b  = 1'b1;   // 藍 OFF
    assign d0 = 1'b1;   // 第 0 顆致能
    assign d1 = 1'b0;
    assign d2 = 1'b0;
    assign d3 = 1'b0;
    assign d4 = 1'b0;
    assign d5 = 1'b0;
endmodule

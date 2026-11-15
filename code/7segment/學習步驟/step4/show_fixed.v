// step4：解碼器 + 顯示固定數字 3（只點亮右邊一位）
module show_fixed (
    input  clk12,
    output a, b, c, d, e, f, g,
    output dig1, dig2
);
    wire [6:0] seg;
    seven_seg_decoder dec(.digit(4'd3), .seg(seg));   // 固定餵 3
    assign {a, b, c, d, e, f, g} = seg;

    assign dig1 = 1'b0;   // 共陰：0 = 啟用右邊一位
    assign dig2 = 1'b1;   // 關閉左邊
endmodule

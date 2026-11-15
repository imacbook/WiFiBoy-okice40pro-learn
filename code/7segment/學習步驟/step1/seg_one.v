// step1：點亮 A 段（最短的顯示程式）
// ⚠️ 重點：7 段顯示器除了「段」之外，還必須「致能位數」才會亮！
module seg_one (
    input  clk12,
    output a,
    output dig1, dig2      // 位數致能（共陰：0 = 致能）
);
    assign a    = 1'b1;    // A 段給 1（共陰：1 = 亮）
    assign dig1 = 1'b0;    // 啟用右邊那一位
    assign dig2 = 1'b0;    // 啟用左邊那一位
endmodule

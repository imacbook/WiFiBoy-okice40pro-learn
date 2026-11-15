// step7：多工示範——兩位數都顯示 8（全部段亮），靠快速切換讓你看起來同時亮
module mux88 (
    input  clk12,
    output a, b, c, d, e, f, g,
    output dig1, dig2
);
    // ~1kHz 切換：12MHz / 12000 = 1kHz
    reg [13:0] refresh = 0;
    reg cur_dig = 0;
    always @(posedge clk12) begin
        if (refresh == 14'd11_999) begin
            refresh <= 0;
            cur_dig <= ~cur_dig;
        end else
            refresh <= refresh + 1;
    end

    assign {a, b, c, d, e, f, g} = 7'b1111111;  // 全亮 = 8
    assign dig1 = cur_dig;     // 共陰：0 = 啟用
    assign dig2 = ~cur_dig;
endmodule

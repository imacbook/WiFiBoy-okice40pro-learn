// step5：混色 8 種（RGB 三色的所有組合）
module rgb_mix (
    input  clk12,
    output r, g, b,
    output d0, d1, d2, d3, d4, d5
);
    reg [23:0] cnt = 0;
    reg [2:0]  combo = 0;
    always @(posedge clk12) begin
        if (cnt == 24'd11_999_999) begin
            cnt   <= 0;
            combo <= combo + 1;   // 0~7 循環
        end else
            cnt <= cnt + 1;
    end

    // combo 的 bit2=R, bit1=G, bit0=B；共陽：0 = 亮
    assign r = ~combo[2];
    assign g = ~combo[1];
    assign b = ~combo[0];

    assign d0 = 1'b1;   // 只開第 0 顆
    assign d1 = 1'b0;
    assign d2 = 1'b0;
    assign d3 = 1'b0;
    assign d4 = 1'b0;
    assign d5 = 1'b0;
endmodule

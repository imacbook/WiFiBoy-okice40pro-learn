// step3：六顆輪流掃描（D0→D5，每秒換一顆）
module rgb_scan (
    input  clk12,
    output r, g, b,
    output d0, d1, d2, d3, d4, d5
);
    reg [23:0] cnt = 0;
    reg [2:0]  scan = 0;
    always @(posedge clk12) begin
        if (cnt == 24'd11_999_999) begin
            cnt  <= 0;
            scan <= (scan == 5) ? 0 : scan + 1;
        end else
            cnt <= cnt + 1;
    end

    // 掃描時固定亮白色（R+G+B），方便看是哪一顆
    assign r = 1'b0;
    assign g = 1'b0;
    assign b = 1'b0;

    assign d0 = (scan == 0);
    assign d1 = (scan == 1);
    assign d2 = (scan == 2);
    assign d3 = (scan == 3);
    assign d4 = (scan == 4);
    assign d5 = (scan == 5);
endmodule

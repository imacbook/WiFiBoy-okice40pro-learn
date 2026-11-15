// step2：同一顆 LED 三色輪流（紅→綠→藍，每秒換）
module rgb_cycle (
    input  clk12,
    output r, g, b,
    output d0, d1, d2, d3, d4, d5
);
    reg [23:0] cnt = 0;
    reg [1:0]  step = 0;
    always @(posedge clk12) begin
        if (cnt == 24'd11_999_999) begin
            cnt  <= 0;
            step <= (step == 2) ? 0 : step + 1;
        end else
            cnt <= cnt + 1;
    end

    // 共陽：0 = 亮
    assign r = (step == 0) ? 1'b0 : 1'b1;
    assign g = (step == 1) ? 1'b0 : 1'b1;
    assign b = (step == 2) ? 1'b0 : 1'b1;

    assign d0 = 1'b1;   // 只開第 0 顆
    assign d1 = 1'b0;
    assign d2 = 1'b0;
    assign d3 = 1'b0;
    assign d4 = 1'b0;
    assign d5 = 1'b0;
endmodule

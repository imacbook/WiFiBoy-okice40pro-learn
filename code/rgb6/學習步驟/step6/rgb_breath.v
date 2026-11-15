// step6：呼吸燈（PWM 控制亮度）
module rgb_breath (
    input  clk12,
    output r, g, b,
    output d0, d1, d2, d3, d4, d5
);
    // 亮度值：0~255 慢慢上升再下降
    reg [7:0] bright = 0;
    reg       up = 1;
    reg [15:0] pwm_cnt = 0;
    always @(posedge clk12) begin
        pwm_cnt <= pwm_cnt + 1;
        if (pwm_cnt == 16'd0) begin
            if (up) begin
                if (bright == 8'd255) up <= 0;
                else bright <= bright + 1;
            end else begin
                if (bright == 8'd0) up <= 1;
                else bright <= bright - 1;
            end
        end
    end

    // PWM：pwm_cnt 的低 8 bit 跟 bright 比
    wire on = (pwm_cnt[7:0] < bright);

    // 共陽：0 = 亮；只有紅色呼吸
    assign r = ~on;
    assign g = 1'b1;
    assign b = 1'b1;

    assign d0 = 1'b1;
    assign d1 = 1'b0;
    assign d2 = 1'b0;
    assign d3 = 1'b0;
    assign d4 = 1'b0;
    assign d5 = 1'b0;
endmodule

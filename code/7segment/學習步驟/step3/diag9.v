// step3：9 隻腳逐腳掃描（一秒點一隻），用來找出「哪個 PMOD 腳對哪個 FPGA 腳」
module diag9 (
    input  clk12,
    output p1, p2, p3, p4, p5, p6, p7, p8, p9
);
    reg [3:0] step = 0;
    reg [23:0] cnt = 0;
    always @(posedge clk12) begin
        if (cnt == 24'd11_999_999) begin
            cnt  <= 0;
            step <= (step == 9) ? 0 : step + 1;
        end else
            cnt <= cnt + 1;
    end
    assign p1 = (step == 1);
    assign p2 = (step == 2);
    assign p3 = (step == 3);
    assign p4 = (step == 4);
    assign p5 = (step == 5);
    assign p6 = (step == 6);
    assign p7 = (step == 7);
    assign p8 = (step == 8);
    assign p9 = (step == 9);
endmodule

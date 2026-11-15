`timescale 1ns/1ps
// WS2812B 時序測試：量測 latch 長度與第一個 bit 的高/低電位週期數
module tb_ws2812b;
    reg clk = 0;
    always #41.667 clk = ~clk;   // 12 MHz

    wire din;
    ws2812b #(.NUM_LEDS(8)) dut(.clk12(clk), .din(din));

    integer r, h, l;

    initial begin
        // 量 latch（din=0 的連續週期數）
        r = 0;
        while (din === 1'b0 && r < 3000) begin
            @(negedge clk);
            r = r + 1;
        end
        // 量第一個高電位
        h = 0;
        while (din === 1'b1 && h < 30) begin
            @(negedge clk);
            h = h + 1;
        end
        // 量第一個低電位
        l = 0;
        while (din === 1'b0 && l < 30) begin
            @(negedge clk);
            l = l + 1;
        end

        $display("latch=%0d 週期（預期 ~1200）", r);
        $display("第一個 bit 高=%0d 週期（預期 5，第一顆紅色 G=0x00 首 bit=0）", h);
        $display("第一個 bit 低=%0d 週期（預期 10）", l);

        if (r >= 1195 && r <= 1210 && h >= 4 && h <= 6 && l >= 9 && l <= 11)
            $display("==> TIMING PASS ==");
        else
            $display("==> TIMING FAIL ==");
        $finish;
    end
endmodule

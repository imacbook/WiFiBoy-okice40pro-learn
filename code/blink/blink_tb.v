`timescale 1ns/1ps

// 05-blink（rgb_test）的測試平台：產生 12 MHz 時脈，觀看計數器與 LED 輸出波形
module blink_tb;

    // 12 MHz 時脈（週期約 83.33 ns，半週期 41.667 ns）
    reg clk12 = 0;
    always #41.667 clk12 = ~clk12;

    wire led_b, led_r;

    // 待測設計（DUT）
    rgb_test dut (
        .clk12(clk12),
        .led_b(led_b),
        .led_r(led_r)
    );

    initial begin
        $dumpfile("blink_sim.vcd");      // 輸出波形檔
        $dumpvars(0, blink_tb);          // 傾印本模組下所有訊號
        #6500000;                        // 跑 6.5 ms（led_r 約 1.365 ms 切換一次）
        $finish;
    end

endmodule

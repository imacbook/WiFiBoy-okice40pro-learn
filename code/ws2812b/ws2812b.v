// WiFiBoy WS2812B PMOD 驅動：單線 NeoPixel 協定（800kHz bit-bang @ 12MHz）
// 12 顆 LED，彩虹色帶隨時間沿燈條流動（動畫）
// 時序：0 bit = 高5低10、1 bit = 高10低5（週期數）；latch = 1200 週期
module ws2812b #(
    parameter NUM_LEDS = 12
)(
    input  clk12,
    output reg din = 0
);
    localparam BIT_CYCLES    = 15;      // 1 bit = 15 週期 = 1.25µs
    localparam T0H = 5,  T0L = BIT_CYCLES - T0H;
    localparam T1H = 10, T1L = BIT_CYCLES - T1H;
    localparam RESET_CYCLES = 1200;    // latch 100µs

    // 12 色彩虹表（GRB 24-bit，MSB 先送）
    function [23:0] color_of;
        input [3:0] idx;
        begin
            case (idx)
                4'd0:  color_of = 24'h00FF00;  // 紅
                4'd1:  color_of = 24'h80FF00;  // 橙
                4'd2:  color_of = 24'hFFFF00;  // 黃
                4'd3:  color_of = 24'hFF8000;  // 黃綠
                4'd4:  color_of = 24'hFF0000;  // 綠
                4'd5:  color_of = 24'hFF0080;  // 青綠
                4'd6:  color_of = 24'hFF00FF;  // 青
                4'd7:  color_of = 24'h8000FF;  // 天藍
                4'd8:  color_of = 24'h0000FF;  // 藍
                4'd9:  color_of = 24'h0080FF;  // 紫
                4'd10: color_of = 24'h00FFFF;  // 洋紅
                4'd11: color_of = 24'h00FF80;  // 粉
                default: color_of = 24'h000000;
            endcase
        end
    endfunction

    // 動畫相位：每 250ms 前進一格，讓彩虹沿燈條流動
    reg [3:0]  phase     = 0;
    reg [23:0] phase_cnt = 0;
    always @(posedge clk12) begin
        if (phase_cnt == 24'd2_999_999) begin
            phase_cnt <= 0;
            phase <= (phase == 4'd11) ? 4'd0 : phase + 1;
        end else
            phase_cnt <= phase_cnt + 1;
    end

    reg [23:0] shift   = 0;
    reg [5:0]  bit_cnt = 0;   // 0..23
    reg [4:0]  led_cnt = 0;   // 0..NUM_LEDS-1
    reg [7:0]  cyc     = 0;   // 0..14
    reg [15:0] rst_cnt = 0;
    reg        sending = 0;

    always @(posedge clk12) begin
        if (!sending) begin
            // latch/reset：din 保持低
            din <= 0;
            if (rst_cnt == RESET_CYCLES - 1) begin
                rst_cnt <= 0;
                sending <= 1;
                led_cnt  <= 0;
                bit_cnt  <= 0;
                cyc      <= 0;
                shift    <= color_of(phase);   // LED 0 的顏色
            end else
                rst_cnt <= rst_cnt + 1;
        end else begin
            // 送出目前 bit
            din <= (cyc < (shift[23] ? T1H : T0H)) ? 1'b1 : 1'b0;
            if (cyc == BIT_CYCLES - 1) begin
                cyc <= 0;
                if (bit_cnt == 23) begin
                    bit_cnt <= 0;
                    if (led_cnt == NUM_LEDS - 1) begin
                        sending <= 0;          // 全部送完，回 latch
                        rst_cnt <= 0;
                    end else begin
                        led_cnt <= led_cnt + 1;
                        shift   <= color_of((led_cnt + 1 + phase) % NUM_LEDS);
                    end
                end else begin
                    bit_cnt <= bit_cnt + 1;
                    shift   <= {shift[22:0], 1'b0};
                end
            end else
                cyc <= cyc + 1;
        end
    end
endmodule

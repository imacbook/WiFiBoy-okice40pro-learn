// ��彩虹沿燈條流動
module ws_flow (
    input  clk12,
    output reg din = 0
);
    localparam NUM_LEDS = 12;
    localparam BIT_CYCLES = 15;
    localparam T0H = 5, T1H = 10;
    localparam RESET_CYCLES = 1200;

    // 動畫相位：每 250ms 前進一格
    reg [3:0]  phase = 0;
    reg [23:0] phase_cnt = 0;
    always @(posedge clk12) begin
        if (phase_cnt == 24'd2_999_999) begin
            phase_cnt <= 0;
            phase <= (phase == 11) ? 0 : phase + 1;
        end else phase_cnt <= phase_cnt + 1;
    end

    function [23:0] color_of(input [4:0] idx);
        reg [4:0] p;
        begin
            p = (idx + phase) % 12;
            case (p)
                0:  color_of = 24'h00FF00;
                1:  color_of = 24'h80FF00;
                2:  color_of = 24'hFFFF00;
                3:  color_of = 24'hFF8000;
                4:  color_of = 24'hFF0000;
                5:  color_of = 24'hFF0080;
                6:  color_of = 24'hFF00FF;
                7:  color_of = 24'h8000FF;
                8:  color_of = 24'h0000FF;
                9:  color_of = 24'h0080FF;
                10: color_of = 24'h00FFFF;
                11: color_of = 24'h00FF80;
                default: color_of = 24'h000000;
            endcase
        end
    endfunction

    reg [23:0] shift;
    reg [5:0]  bit_cnt;
    reg [4:0]  led_cnt;
    reg [3:0]  cyc;
    reg [15:0] rst_cnt;
    reg        sending;

    always @(posedge clk12) begin
        if (!sending) begin
            din <= 0;
            if (rst_cnt == RESET_CYCLES-1) begin
                rst_cnt <= 0; sending <= 1; led_cnt <= 0; bit_cnt <= 0; cyc <= 0;
                shift <= color_of(0);
            end else rst_cnt <= rst_cnt + 1;
        end else begin
            din <= (cyc < (shift[23] ? T1H : T0H)) ? 1'b1 : 1'b0;
            if (cyc == BIT_CYCLES-1) begin
                cyc <= 0;
                if (bit_cnt == 23) begin
                    bit_cnt <= 0;
                    if (led_cnt == NUM_LEDS-1) begin
                        sending <= 0; rst_cnt <= 0;
                    end else begin
                        led_cnt <= led_cnt + 1;
                        shift <= color_of(led_cnt + 1);
                    end
                end else begin
                    bit_cnt <= bit_cnt + 1;
                    shift <= {shift[22:0], 1'b0};
                end
            end else cyc <= cyc + 1;
        end
    end
endmodule

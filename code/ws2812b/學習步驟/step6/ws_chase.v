// ��一顆光點沿燈條跑
module ws_chase (
    input  clk12,
    output reg din = 0
);
    localparam NUM_LEDS = 12;
    localparam BIT_CYCLES = 15;
    localparam T0H = 5, T1H = 10;
    localparam RESET_CYCLES = 1200;

    reg [3:0] pos = 0;
    reg [23:0] pos_cnt = 0;
    always @(posedge clk12) begin
        if (pos_cnt == 24'd1_499_999) begin
            pos_cnt <= 0;
            pos <= (pos == 11) ? 0 : pos + 1;
        end else pos_cnt <= pos_cnt + 1;
    end

    function [23:0] color_of(input [4:0] idx);
        begin
            color_of = (idx == pos) ? 24'h00FF00 : 24'h000000;
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

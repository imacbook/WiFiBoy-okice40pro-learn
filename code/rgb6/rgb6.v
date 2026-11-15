// WiFiBoy RGB6 LED PMOD 驅動：6 顆 RGB LED（3 色線 × 6 選線矩陣）
// COMMON_ANODE：0 = 共陰（色線高亮、選線低致能）；1 = 共陽
module rgb6 #(
    parameter COMMON_ANODE = 1
)(
    input  clk12,
    output r, g, b,                    // 3 條色線（6 顆共用）
    output d0, d1, d2, d3, d4, d5      // 6 條選線（各一顆）
);
    // 掃描：輪流致能 6 顆 LED（約 2kHz/顆，看不出閃爍）
    reg [2:0] scan = 0;
    reg [15:0] scan_cnt = 0;
    always @(posedge clk12) begin
        if (scan_cnt == 16'd5999) begin
            scan_cnt <= 0;
            scan <= (scan == 3'd5) ? 3'd0 : scan + 1;
        end else
            scan_cnt <= scan_cnt + 1;
    end

    // 每顆 LED 的顏色（demo 固定色）
    function [2:0] led_color;
        input [2:0] idx;
        begin
            case (idx)
                3'd0: led_color = 3'b100;  // 紅
                3'd1: led_color = 3'b010;  // 綠
                3'd2: led_color = 3'b001;  // 藍
                3'd3: led_color = 3'b110;  // 黃
                3'd4: led_color = 3'b101;  // 紫
                3'd5: led_color = 3'b011;  // 青
                default: led_color = 3'b000;
            endcase
        end
    endfunction

    wire [2:0] color = led_color(scan);

    // 色線：共陰高亮、共陽低亮
    assign r = COMMON_ANODE ? ~color[2] : color[2];
    assign g = COMMON_ANODE ? ~color[1] : color[1];
    assign b = COMMON_ANODE ? ~color[0] : color[0];

    // 選線：共陰低致能、共陽高致能
    reg [5:0] sel;
    always @* begin
        case (scan)
            3'd0: sel = 6'b000001;
            3'd1: sel = 6'b000010;
            3'd2: sel = 6'b000100;
            3'd3: sel = 6'b001000;
            3'd4: sel = 6'b010000;
            3'd5: sel = 6'b100000;
            default: sel = 6'b000000;
        endcase
    end
    wire [5:0] sel_out = COMMON_ANODE ? sel : ~sel;
    assign d0 = sel_out[0];
    assign d1 = sel_out[1];
    assign d2 = sel_out[2];
    assign d3 = sel_out[3];
    assign d4 = sel_out[4];
    assign d5 = sel_out[5];
endmodule

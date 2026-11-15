// WiFiBoy 7-segment PMOD 驅動：2 位數直驅，顯示 00~99 每秒 +1
// COMMON_ANODE：1 = 共陽（段低電位點亮，位數高電位致能）；0 = 共陰
module seven_seg #(
    parameter COMMON_ANODE = 0
)(
    input  clk12,                        // 12 MHz
    output seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g,
    output dig1, dig2
);
    // ---- 0~99 計數（每秒 +1）----
    reg [3:0] units = 0;
    reg [3:0] tens  = 0;
    reg [23:0] tick = 0;
    always @(posedge clk12) begin
        if (tick == 24'd11_999_999) begin
            tick <= 0;
            if (units == 4'd9) begin
                units <= 0;
                tens <= (tens == 4'd9) ? 4'd0 : tens + 1;
            end else
                units <= units + 1;
        end else
            tick <= tick + 1;
    end

    // ---- 顯示刷新（約 1 kHz 切換位數）----
    reg [13:0] refresh = 0;
    reg cur_dig = 0;        // 0 = 顯示個位, 1 = 顯示十位
    always @(posedge clk12) begin
        if (refresh == 14'd11_999) begin
            refresh <= 0;
            cur_dig <= ~cur_dig;
        end else
            refresh <= refresh + 1;
    end

    // ---- 段解碼（輸出為共陰 active-high 段碼）----
    wire [6:0] seg_units, seg_tens;   // {a,b,c,d,e,f,g}
    seven_seg_decoder dec_units(.digit(units), .seg(seg_units));
    seven_seg_decoder dec_tens (.digit(tens),  .seg(seg_tens));

    // ---- 多工選擇 + 極性 ----
    wire [6:0] seg_pattern = cur_dig ? seg_tens : seg_units;
    wire [6:0] seg = COMMON_ANODE ? ~seg_pattern : seg_pattern;
    assign {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g} = seg;

    // ---- 位數致能（共陽=高電位致能；共陰=低電位致能）----
    assign dig1 = COMMON_ANODE ? ~cur_dig : cur_dig;
    assign dig2 = COMMON_ANODE ?  cur_dig : ~cur_dig;

endmodule

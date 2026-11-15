// step8：0~99 計數（每秒 +1），兩位數用多工顯示
module count99 (
    input  clk12,
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
                tens  <= (tens == 4'd9) ? 4'd0 : tens + 1;
            end else
                units <= units + 1;
        end else
            tick <= tick + 1;
    end

    // ---- 多工掃描（~1kHz）----
    reg [13:0] refresh = 0;
    reg cur_dig = 0;
    always @(posedge clk12) begin
        if (refresh == 14'd11_999) begin
            refresh <= 0;
            cur_dig <= ~cur_dig;
        end else
            refresh <= refresh + 1;
    end

    // ---- 解碼 + 多工選擇 ----
    wire [6:0] seg_units, seg_tens;
    seven_seg_decoder dec_units(.digit(units), .seg(seg_units));
    seven_seg_decoder dec_tens (.digit(tens),  .seg(seg_tens));
    wire [6:0] seg = cur_dig ? seg_tens : seg_units;
    assign {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g} = seg;

    assign dig1 = cur_dig;    // 共陰：0 = 啟用
    assign dig2 = ~cur_dig;
endmodule

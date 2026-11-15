// step9：完整版——加上共陰/共陽切換
module seven_seg_polarity #(
    parameter COMMON_ANODE = 0    // 0 = 共陰；1 = 共陽
)(
    input  clk12,
    output seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g,
    output dig1, dig2
);
    reg [3:0] units = 0, tens = 0;
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

    reg [13:0] refresh = 0;
    reg cur_dig = 0;
    always @(posedge clk12) begin
        if (refresh == 14'd11_999) begin
            refresh <= 0;
            cur_dig <= ~cur_dig;
        end else
            refresh <= refresh + 1;
    end

    wire [6:0] seg_units, seg_tens;
    seven_seg_decoder dec_units(.digit(units), .seg(seg_units));
    seven_seg_decoder dec_tens (.digit(tens),  .seg(seg_tens));

    wire [6:0] seg_pattern = cur_dig ? seg_tens : seg_units;
    wire [6:0] seg = COMMON_ANODE ? ~seg_pattern : seg_pattern;
    assign {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g} = seg;

    // 共陰：位數低電位致能；共陽：高電位致能
    assign dig1 = COMMON_ANODE ? ~cur_dig : cur_dig;
    assign dig2 = COMMON_ANODE ?  cur_dig : ~cur_dig;
endmodule

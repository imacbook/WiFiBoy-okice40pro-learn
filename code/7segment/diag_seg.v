// 7-seg 診斷：兩個位數都致能（共陰：dig LOW），
// 每秒輪流點亮一個段：A -> B -> C -> D -> E -> F -> G -> 全滅 -> 循環
module diag_seg (
    input  clk12,
    output seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g,
    output dig1, dig2
);
    assign dig1 = 1'b0;   // 兩位數都致能（共陰假設）
    assign dig2 = 1'b0;

    reg [2:0] step = 0;
    reg [23:0] cnt = 0;
    always @(posedge clk12) begin
        if (cnt == 24'd11_999_999) begin
            cnt <= 0;
            step <= (step == 7) ? 0 : step + 1;
        end else
            cnt <= cnt + 1;
    end

    reg [6:0] seg;
    always @* begin
        case (step)
            0: seg = 7'b1000000;  // A
            1: seg = 7'b0100000;  // B
            2: seg = 7'b0010000;  // C
            3: seg = 7'b0001000;  // D
            4: seg = 7'b0000100;  // E
            5: seg = 7'b0000010;  // F
            6: seg = 7'b0000001;  // G
            7: seg = 7'b0000000;  // 全滅
        endcase
    end
    assign {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g} = seg;
endmodule

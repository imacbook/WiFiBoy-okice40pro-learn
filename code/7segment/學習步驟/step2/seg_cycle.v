// step2：每秒輪流點亮 A→B→C→D→E→F→G→全滅
// ⚠️ 位數也要致能才會亮（共陰：0 = 致能）
module seg_cycle (
    input  clk12,
    output a, b, c, d, e, f, g,
    output dig1, dig2
);
    // 每秒換一段（12MHz 數 1200 萬次 = 1 秒）
    reg [2:0] step = 0;
    reg [23:0] cnt = 0;
    always @(posedge clk12) begin
        if (cnt == 24'd11_999_999) begin
            cnt  <= 0;
            step <= (step == 7) ? 0 : step + 1;
        end else
            cnt <= cnt + 1;
    end

    // 用 case 決定哪一段亮
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
            7: seg = 7'b0000000;  // 全滅（休息一下）
        endcase
    end
    assign {a, b, c, d, e, f, g} = seg;

    assign dig1 = 1'b0;   // 啟用右邊一位
    assign dig2 = 1'b0;   // 啟用左邊一位
endmodule

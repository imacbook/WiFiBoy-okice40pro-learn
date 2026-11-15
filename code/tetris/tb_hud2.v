`timescale 1ns/1ps
module tb_hud2;
    reg [9:0] hcnt = 0, vcnt = 0;
    reg [15:0] score = 0;
    reg [2:0] level = 0, next_type = 0;
    wire hud_on;
    hud dut(.hcnt(hcnt), .vcnt(vcnt), .score(score), .level(level), .next_type(next_type), .hud_on(hud_on));
    // 直接測 glyph 函數
    initial begin
        // 掃 S 字形第一列（row 0 = 0x3C = 00111100），col 2-5 應為 1
        $display("S row0 各 col 的 glyph bit：");
        for (hcnt = 420; hcnt < 428; hcnt = hcnt + 1) begin
            vcnt = 100; #1;
            $write("%b", hud_on);
        end
        $write("\n");
        // 掃 SCORE 標題一整列（y=100）
        $display("y=100 整列（420..500）的 hud_on：");
        vcnt = 100;
        for (hcnt = 420; hcnt < 500; hcnt = hcnt + 1) begin
            #1; $write("%b", hud_on);
        end
        $write("\n");
        $finish;
    end
endmodule

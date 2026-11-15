`timescale 1ns/1ps
module tb_hud3;
    reg [9:0] hcnt = 422, vcnt = 100;
    reg [15:0] score = 0; reg [2:0] level = 0, next_type = 0;
    wire hud_on;
    hud dut(.hcnt(hcnt), .vcnt(vcnt), .score(score), .level(level), .next_type(next_type), .hud_on(hud_on));
    initial begin
        #1;
        $display("S(422,100) hud_on=%b（應為 1）", hud_on);
        // 試不同列：S row 1 = 0x66 = 01100110，col 1,2,5,6
        vcnt = 101; hcnt = 421; #1;
        $display("S(421,101) hud_on=%b（應為 1）", hud_on);
        // 檢查 score digit '1'（score=12345, d4=1）：'1' row0 = 0x18，col 3,4
        score = 12345;
        vcnt = 116; hcnt = 423; #1;
        $display("'1'(423,116) hud_on=%b（應為 1）", hud_on);
        $finish;
    end
endmodule

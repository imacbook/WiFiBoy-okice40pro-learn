`timescale 1ns/1ps
module tb_hud;
    reg [9:0] hcnt = 0, vcnt = 0;
    reg [15:0] score = 0;
    reg [2:0] level = 0, next_type = 0;
    wire hud_on;
    hud dut(.hcnt(hcnt), .vcnt(vcnt), .score(score), .level(level), .next_type(next_type), .hud_on(hud_on));
    integer x, y, hits;
    initial begin
        score = 12345; level = 3; next_type = 2;
        // 掃描 (410..490, 90..210) 看 hud_on 有沒有 1
        hits = 0;
        for (y = 90; y < 210; y = y+1)
            for (x = 410; x < 490; x = x+1) begin
                hcnt = x; vcnt = y; #1;
                if (hud_on) hits = hits + 1;
            end
        $display("分數/等級區域命中像素數 = %0d（應 > 0）", hits);
        $finish;
    end
endmodule

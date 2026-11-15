`timescale 1ns/1ps
module tb_disp2;
    reg clk = 0; reg start = 0;
    wire [319:0] board, display_board; wire game_over;
    game #(.GRAV(25'd10)) dut(.clk(clk), .start(start), .board(board), .display_board(display_board), .game_over(game_over));
    always #20 clk = ~clk;
    initial begin
        $dumpfile("tb_disp2.vcd"); $dumpvars(0, tb_disp2);
        start = 1;
        // 200 週期後（約 8us，第一個 I 已鎖定，O 方塊正落下）
        repeat (200) @(posedge clk);
        $display("t=%0t state=%0d O方塊位置 display[20]=%b [21]=%b [36]=%b [37]=%b（落下中應為 1）",
                 $time, dut.state, display_board[20], display_board[21], display_board[36], display_board[37]);
        $finish;
    end
endmodule

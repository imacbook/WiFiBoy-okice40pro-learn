`timescale 1ns/1ps
module tb_disp;
    reg clk = 0; reg start = 0;
    wire [319:0] board, display_board; wire game_over;
    game #(.GRAV(25'd10)) dut(.clk(clk), .start(start), .board(board), .display_board(display_board), .game_over(game_over));
    always #20 clk = ~clk;
    initial begin
        $dumpfile("tb_disp.vcd"); $dumpvars(0, tb_disp);
        start = 1;
        // 監測 display_board 中 I 方塊（起點 (3,0)，block y=1 → 位置 {1,3}=19）是否出現
        repeat (200) @(posedge clk);
        $display("t=%0t: display_board[19]=%b display_board[307]=%b (應先看到上方方塊 [19]，後才底部 [307])", $time, display_board[19], display_board[307]);
        repeat (200) @(posedge clk);
        $display("t=%0t: display_board[19]=%b display_board[307]=%b", $time, display_board[19], display_board[307]);
        $finish;
    end
endmodule

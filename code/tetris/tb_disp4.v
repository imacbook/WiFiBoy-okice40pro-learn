`timescale 1ns/1ps
module tb_disp4;
    reg clk = 0; reg start = 0;
    wire [319:0] board, display_board; wire game_over;
    game #(.GRAV(25'd10)) dut(.clk(clk), .start(start), .board(board), .display_board(display_board), .game_over(game_over));
    always #20 clk = ~clk;
    integer i;
    initial begin
        $dumpfile("tb_disp4.vcd"); $dumpvars(0, tb_disp4);
        start = 1;
        repeat (240) @(posedge clk);  // O 方塊落下中
        // 找 display_board 中前 10 列（0-9）的 set bits
        $display("t=%0t state=%0d 前 10 列的 set bits：", $time, dut.state);
        for (i = 0; i < 160; i = i+1)
            if (display_board[i]) $write("%0d ", i);
        $write("\n");
        $display("board 前 10 列的 set bits：");
        for (i = 0; i < 160; i = i+1)
            if (board[i]) $write("%0d ", i);
        $write("\n");
        $finish;
    end
endmodule

`timescale 1ns/1ps
module tb_disp3;
    reg clk = 0; reg start = 0;
    wire [319:0] board, display_board; wire game_over;
    game #(.GRAV(25'd10)) dut(.clk(clk), .start(start), .board(board), .display_board(display_board), .game_over(game_over));
    always #20 clk = ~clk;
    initial begin
        $dumpfile("tb_disp3.vcd"); $dumpvars(0, tb_disp3);
        start = 1;
        repeat (240) @(posedge clk);  // ~9.6us，O 方塊正落下
        $display("t=%0t state=%0d O方塊(落下中) display[20]=%b [21]=%b [36]=%b [37]=%b",
                 $time, dut.state, display_board[20], display_board[21], display_board[36], display_board[37]);
        repeat (60) @(posedge clk);  // 又落 6 格
        $display("t=%0t state=%0d O方塊(更低) display[52]=%b [53]=%b [68]=%b [69]=%b",
                 $time, dut.state, display_board[52], display_board[53], display_board[68], display_board[69]);
        $finish;
    end
endmodule

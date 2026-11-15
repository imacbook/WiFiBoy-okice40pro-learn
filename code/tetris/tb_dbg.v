`timescale 1ns/1ps
module tb_dbg;
    reg clk = 0; reg start = 0;
    wire [319:0] board; wire game_over;
    game #(.GRAV(25'd10)) dut(.clk(clk), .start(start), .board(board), .game_over(game_over));
    always #20 clk = ~clk;
    reg [1:0] ps = 0;
    always @(posedge clk) begin
        if (dut.state != ps) begin
            $display("t=%0t state=%0d board[307..310]=%b%b%b%b", $time, dut.state,
                     board[307], board[308], board[309], board[310]);
            ps <= dut.state;
        end
    end
    initial begin
        $dumpfile("tb_dbg.vcd"); $dumpvars(0, tb_dbg);
        start = 1;
        #3000000;  // 3ms
        $finish;
    end
endmodule

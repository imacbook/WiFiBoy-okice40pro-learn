`timescale 1ns/1ps
module tb_feat;
    reg clk = 0; reg start = 0; reg restart = 0;
    wire [15:0] rdata; wire [4:0] g_raddr, g_waddr; wire [15:0] g_wdata; wire g_read, g_we;
    wire [3:0] piece_x; wire [4:0] piece_y; wire [1:0] piece_rot; wire [2:0] piece_type; wire piece_active;
    wire [15:0] score; wire [2:0] level; wire [8:0] lines; wire [2:0] next_type; wire game_over;
    game dut(.clk(clk),.start(start),.move_left(0),.move_right(0),.rotate_cw(0),.rotate_ccw(0),.soft_drop(0),.soft_held(0),.hard_drop(0),.restart(restart),.bram_rdata(rdata),.g_raddr(g_raddr),.g_read(g_read),.g_waddr(g_waddr),.g_wdata(g_wdata),.g_we(g_we),.piece_x(piece_x),.piece_y(piece_y),.piece_rot(piece_rot),.piece_type(piece_type),.piece_active(piece_active),.score(score),.level(level),.lines(lines),.next_type(next_type),.game_over(game_over));
    board_ram bram(.clk(clk),.raddr(g_raddr),.waddr(g_waddr),.wdata(g_wdata),.we(g_we),.rdata(rdata));
    always #20 clk = ~clk;
    reg [4:0] prev_y = 0; integer locks = 0;
    always @(posedge clk) begin
        if (start && piece_y < prev_y) begin
            locks = locks + 1;
            $display("t=%0t 鎖定 #%0d type=%0d score=%0d lines=%0d level=%0d", $time, locks, piece_type, score, lines, level);
        end
        prev_y <= piece_y;
    end
    initial begin
        $dumpfile("tb_feat.vcd"); $dumpvars(0, tb_feat);
        start = 1;
        repeat (1200) @(posedge clk);
        $display("結束：locks=%0d score=%0d lines=%0d level=%0d next=%0d over=%0d", locks, score, lines, level, next_type, game_over);
        $finish;
    end
endmodule

`timescale 1ns/1ps
module tb_speed;
    reg clk = 0; reg start = 0; reg soft_held = 0;
    wire [15:0] rdata; wire [4:0] g_raddr, g_waddr; wire [15:0] g_wdata; wire g_read, g_we;
    wire [3:0] piece_x; wire [4:0] piece_y; wire [1:0] piece_rot; wire [2:0] piece_type; wire piece_active;
    wire [15:0] score; wire [2:0] level; wire [8:0] lines; wire [2:0] next_type; wire game_over;
    wire snd_lock, snd_clear;
    game dut(.clk(clk),.start(start),.move_left(0),.move_right(0),.rotate_cw(0),.rotate_ccw(0),.soft_drop(0),.soft_held(soft_held),.hard_drop(0),.restart(0),.bram_rdata(rdata),.g_raddr(g_raddr),.g_read(g_read),.g_waddr(g_waddr),.g_wdata(g_wdata),.g_we(g_we),.piece_x(piece_x),.piece_y(piece_y),.piece_rot(piece_rot),.piece_type(piece_type),.piece_active(piece_active),.score(score),.level(level),.lines(lines),.next_type(next_type),.game_over(game_over),.snd_lock(snd_lock),.snd_clear(snd_clear));
    board_ram bram(.clk(clk),.raddr(g_raddr),.waddr(g_waddr),.wdata(g_wdata),.we(g_we),.rdata(rdata));
    always #20 clk = ~clk;
    initial begin
        start = 1;
        #1000;
        $display("level=%0d grav_th=%0d gcnt=%0d（soft_held=%0d）", level, dut.grav_th, dut.gcnt, soft_held);
        // 模擬按「下」鍵看 soft_held 效果
        soft_held = 1;
        #1000;
        $display("按「下」後 grav_th=%0d（應變小=變快）", dut.grav_th);
        $finish;
    end
endmodule

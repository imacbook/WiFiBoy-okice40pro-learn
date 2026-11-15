`timescale 1ns/1ps
module tb_mem;
    reg clk = 0; reg start = 0;
    wire [15:0] rdata; wire [4:0] g_raddr, g_waddr; wire [15:0] g_wdata; wire g_read, g_we;
    wire [3:0] piece_x; wire [4:0] piece_y; wire [1:0] piece_rot; wire [2:0] piece_type; wire piece_active;
    wire game_over;
    game #(.GRAV(25'd10)) dut(.clk(clk),.start(start),.move_left(0),.move_right(0),.rotate_cw(0),.rotate_ccw(0),.soft_drop(0),.soft_held(0),.hard_drop(0),.bram_rdata(rdata),.g_raddr(g_raddr),.g_read(g_read),.g_waddr(g_waddr),.g_wdata(g_wdata),.g_we(g_we),.piece_x(piece_x),.piece_y(piece_y),.piece_rot(piece_rot),.piece_type(piece_type),.piece_active(piece_active),.game_over(game_over));
    board_ram bram(.clk(clk),.raddr(g_raddr),.waddr(g_waddr),.wdata(g_wdata),.we(g_we),.rdata(rdata));
    always #20 clk = ~clk;
    integer r;
    initial begin
        $dumpfile("tb_mem.vcd"); $dumpvars(0, tb_mem);
        start = 1;
        repeat (900) @(posedge clk);  // 2-3 個方塊落下
        $display("=== 棋盤（下方列）===");
        for (r = 19; r >= 14; r = r-1)
            $display("row %0d: %b", r, bram.mem[r][9:0]);
        $finish;
    end
endmodule

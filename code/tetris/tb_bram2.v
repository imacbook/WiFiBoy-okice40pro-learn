`timescale 1ns/1ps
module tb_bram2;
    reg clk = 0; reg start = 0;
    reg ml=0,mr=0,rcw=0,rccw=0,sd=0,sh=0,hd=0;
    wire [15:0] rdata; wire [4:0] g_raddr, g_waddr; wire [15:0] g_wdata; wire g_read, g_we;
    wire [3:0] piece_x; wire [4:0] piece_y; wire [1:0] piece_rot; wire [2:0] piece_type; wire piece_active;
    wire game_over;
    game #(.GRAV(25'd10)) dut(.clk(clk),.start(start),.move_left(ml),.move_right(mr),.rotate_cw(rcw),.rotate_ccw(rccw),.soft_drop(sd),.soft_held(sh),.hard_drop(hd),.bram_rdata(rdata),.g_raddr(g_raddr),.g_read(g_read),.g_waddr(g_waddr),.g_wdata(g_wdata),.g_we(g_we),.piece_x(piece_x),.piece_y(piece_y),.piece_rot(piece_rot),.piece_type(piece_type),.piece_active(piece_active),.game_over(game_over));
    board_ram bram(.clk(clk),.raddr(g_raddr),.waddr(g_waddr),.wdata(g_wdata),.we(g_we),.rdata(rdata));
    always #20 clk = ~clk;
    reg [2:0] ps = 3'd7;
    always @(posedge clk) begin
        if (dut.state != ps) begin
            $display("t=%0t state %0d->%0d  y=%0d", $time, ps, dut.state, piece_y);
            ps <= dut.state;
        end
        if (game_over) $display("t=%0t GAME OVER y=%0d", $time, piece_y);
    end
    initial begin
        $dumpfile("tb_bram2.vcd"); $dumpvars(0, tb_bram2);
        start = 1;
        repeat (100) @(posedge clk);
        $finish;
    end
endmodule

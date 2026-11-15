`timescale 1ns/1ps
module tb_bram;
    reg clk = 0; reg start = 0;
    reg move_left=0, move_right=0, rotate_cw=0, rotate_ccw=0, soft_drop=0, soft_held=0, hard_drop=0;
    wire [15:0] rdata; wire [4:0] raddr, waddr; wire [15:0] wdata; wire we;
    wire [4:0] g_raddr, g_waddr; wire [15:0] g_wdata; wire g_read, g_we;
    wire [3:0] piece_x; wire [4:0] piece_y; wire [1:0] piece_rot; wire [2:0] piece_type; wire piece_active;
    wire game_over;

    game #(.GRAV(25'd10)) dut(
        .clk(clk), .start(start),
        .move_left(move_left), .move_right(move_right),
        .rotate_cw(rotate_cw), .rotate_ccw(rotate_ccw),
        .soft_drop(soft_drop), .soft_held(soft_held), .hard_drop(hard_drop),
        .bram_rdata(rdata), .g_raddr(g_raddr), .g_read(g_read),
        .g_waddr(g_waddr), .g_wdata(g_wdata), .g_we(g_we),
        .piece_x(piece_x), .piece_y(piece_y), .piece_rot(piece_rot),
        .piece_type(piece_type), .piece_active(piece_active),
        .game_over(game_over)
    );
    board_ram bram(.clk(clk), .raddr(g_raddr), .waddr(g_waddr), .wdata(g_wdata), .we(g_we), .rdata(rdata));

    always #20 clk = ~clk;

    reg [4:0] prev_y = 0;
    integer locks = 0;
    always @(posedge clk) begin
        if (start && piece_y < prev_y) begin
            locks = locks + 1;
            $display("t=%0t 鎖定 #%0d（舊 type=%0d）", $time, locks, piece_type);
        end
        prev_y <= piece_y;
    end

    initial begin
        $dumpfile("tb_bram.vcd"); $dumpvars(0, tb_bram);
        start = 1;
        repeat (300) @(posedge clk);
        // 試按左鍵
        move_left = 1; repeat (1) @(posedge clk); move_left = 0;
        repeat (100) @(posedge clk);
        $display("piece_x=%0d piece_y=%0d type=%0d rot=%0d active=%0d game_over=%0d",
                 piece_x, piece_y, piece_type, piece_rot, piece_active, game_over);
        $finish;
    end
endmodule

// 遊戲邏輯測試：快速重力（GRAV=10），觀察方塊落下、鎖定、重生、消行
`timescale 1ns/1ps
module tb_game;
    reg clk = 0;
    reg start = 0;
    wire [319:0] board;
    wire game_over;

    game #(.GRAV(25'd10)) dut(.clk(clk), .start(start), .board(board), .game_over(game_over));

    always #20 clk = ~clk;   // 25MHz

    // 監測鎖定（cur_y 變小 = 重生）
    reg [4:0] prev_y = 0;
    reg [2:0] prev_type = 0;
    integer lock_cnt = 0;
    always @(posedge clk) begin
        if (start && dut.cur_y < prev_y) begin
            lock_cnt = lock_cnt + 1;
            $display("t=%0t: 鎖定 #%0d 舊方塊 type=%0d → 新方塊 type=%0d",
                     $time, lock_cnt, prev_type, dut.cur_type);
        end
        prev_y <= dut.cur_y;
        prev_type <= dut.cur_type;
    end

    task print_board;
        integer r, c;
        begin
            $display("=== 棋盤（row 0 在上）===");
            for (r = 0; r < 20; r = r + 1) begin
                for (c = 0; c < 10; c = c + 1)
                    $write(board[r*16+c] ? "#" : ".");
                $write("\n");
            end
        end
    endtask

    initial begin
        $dumpfile("tb_game.vcd");
        $dumpvars(0, tb_game);
        start = 1;
        #4000;  print_board;
        #8000;  print_board;
        #8000;  print_board;
        $display("game_over=%0d", game_over);
        $finish;
    end
endmodule

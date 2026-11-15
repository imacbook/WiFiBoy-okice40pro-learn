// 棋盤渲染：讀 BRAM（已鎖定棋盤）+ 落下方塊（組合）+ 邊框
module board_render (
    input  pclk,
    input  [9:0] hcnt, vcnt,
    input  [15:0] bram_rdata,    // 已鎖定棋盤的列資料（1 週期延遲）
    input  signed [4:0] piece_x,
    input  [4:0]  piece_y,
    input  [1:0]  piece_rot,
    input  [2:0]  piece_type,
    input         piece_active,
    output [4:0]  renderer_raddr, // 讀位址 = row
    output [5:0]  rgb
);
    // ---- 方塊定義（與 game.v 相同，供落下方塊命中判斷）----
    function [3:0] spawn_xy;
        input [2:0] type; input [1:0] idx;
        reg [1:0] sx, sy;
        begin
            case ({type, idx})
                5'd0:  {sx,sy}={2'd0,2'd1}; 5'd1:  {sx,sy}={2'd1,2'd1};
                5'd2:  {sx,sy}={2'd2,2'd1}; 5'd3:  {sx,sy}={2'd3,2'd1};
                5'd4:  {sx,sy}={2'd1,2'd1}; 5'd5:  {sx,sy}={2'd2,2'd1};
                5'd6:  {sx,sy}={2'd1,2'd2}; 5'd7:  {sx,sy}={2'd2,2'd2};
                5'd8:  {sx,sy}={2'd1,2'd0}; 5'd9:  {sx,sy}={2'd0,2'd1};
                5'd10: {sx,sy}={2'd1,2'd1}; 5'd11: {sx,sy}={2'd2,2'd1};
                5'd12: {sx,sy}={2'd1,2'd0}; 5'd13: {sx,sy}={2'd2,2'd0};
                5'd14: {sx,sy}={2'd0,2'd1}; 5'd15: {sx,sy}={2'd1,2'd1};
                5'd16: {sx,sy}={2'd0,2'd0}; 5'd17: {sx,sy}={2'd1,2'd0};
                5'd18: {sx,sy}={2'd1,2'd1}; 5'd19: {sx,sy}={2'd2,2'd1};
                5'd20: {sx,sy}={2'd0,2'd0}; 5'd21: {sx,sy}={2'd0,2'd1};
                5'd22: {sx,sy}={2'd1,2'd1}; 5'd23: {sx,sy}={2'd2,2'd1};
                5'd24: {sx,sy}={2'd2,2'd0}; 5'd25: {sx,sy}={2'd0,2'd1};
                5'd26: {sx,sy}={2'd1,2'd1}; 5'd27: {sx,sy}={2'd2,2'd1};
                default: {sx,sy}={2'd0,2'd0};
            endcase
            spawn_xy = {sx, sy};
        end
    endfunction

    function [3:0] block_xy;
        input [2:0] type; input [1:0] rot; input [1:0] idx;
        reg [1:0] sx, sy, rx, ry;
        begin
            {sx,sy} = spawn_xy(type, idx);
            case (rot)
                2'd0: begin rx=sx; ry=sy; end
                2'd1: begin rx=2'd3-sy; ry=sx; end
                2'd2: begin rx=2'd3-sx; ry=2'd3-sy; end
                2'd3: begin rx=sy; ry=2'd3-sx; end
                default: begin rx=sx; ry=sy; end
            endcase
            block_xy = {rx, ry};
        end
    endfunction

    // 棋盤：10×20，每格 16×16 px，原點 (240,80)
    reg [9:0] bx = 0, by = 0;
    always @(posedge pclk) begin
        bx <= hcnt - 10'd240;
        by <= vcnt - 10'd80;
    end

    // 對齊 BRAM 的 1 週期延遲：暫存 row/col/border/in
    reg [4:0] row_r = 0;
    reg [3:0] col_r = 0;
    reg border_r = 0, in_r = 0;
    always @(posedge pclk) begin
        row_r   <= by[8:4];
        col_r   <= bx[7:4];
        border_r <= (bx < 10'd2) || (bx >= 10'd158) || (by < 10'd2) || (by >= 10'd318);
        in_r    <= (bx < 10'd160) && (by < 10'd320);
    end

    assign renderer_raddr = by[8:4];   // row

    // 已鎖定棋盤 cell
    wire locked = bram_rdata[col_r];

    // 落下方塊 cell（4 個 block 是否命中目前 (row_r, col_r)）
    wire [3:0] pb0 = block_xy(piece_type, piece_rot, 2'd0);
    wire [3:0] pb1 = block_xy(piece_type, piece_rot, 2'd1);
    wire [3:0] pb2 = block_xy(piece_type, piece_rot, 2'd2);
    wire [3:0] pb3 = block_xy(piece_type, piece_rot, 2'd3);
    wire falling = piece_active && (
        ((piece_x + $signed({3'b0, pb0[3:2]}) == col_r) && (piece_y + pb0[1:0] == row_r)) ||
        ((piece_x + $signed({3'b0, pb1[3:2]}) == col_r) && (piece_y + pb1[1:0] == row_r)) ||
        ((piece_x + $signed({3'b0, pb2[3:2]}) == col_r) && (piece_y + pb2[1:0] == row_r)) ||
        ((piece_x + $signed({3'b0, pb3[3:2]}) == col_r) && (piece_y + pb3[1:0] == row_r))
    );

    wire filled = locked | falling;
    assign rgb = in_r ? (border_r ? 6'b01_01_01 :
                         filled   ? 6'b11_11_11 : 6'b00_00_00)
                      : 6'b00_00_00;
endmodule

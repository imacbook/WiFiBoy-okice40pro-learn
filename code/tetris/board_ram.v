// 棋盤 BRAM：20 列 × 16 位元（用前 10 位元），單一讀寫埠、同步讀（1 週期延遲）
// 行為描述，yosys 會推斷成 iCE40 的硬體 BRAM（SB_RAM40_4K）
module board_ram (
    input  clk,
    input  [4:0] raddr,     // 讀位址（0..19）
    input  [4:0] waddr,     // 寫位址（0..19）
    input  [15:0] wdata,
    input  we,
    output reg [15:0] rdata
);
    reg [15:0] mem [0:31];  // 32 字（用 0..19）
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) mem[i] = 16'h0;   // 初始為空棋盤
    end

    always @(posedge clk) begin
        if (we)
            mem[waddr] <= wdata;
        rdata <= mem[raddr];
    end
endmodule

// PLL：12 MHz -> 25.125 MHz（供 640x480@60 VGA 使用）
// 由 icepll 產生：DIVR=0, DIVF=66, DIVQ=5, FILTER_RANGE=1
module pll (
    input  clock_in,
    output clock_out,
    output locked
);
    SB_PLL40_PAD #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),      // DIVR = 0
        .DIVF(7'b1000010),   // DIVF = 66
        .DIVQ(3'b101),       // DIVQ = 5
        .FILTER_RANGE(3'b001)
    ) uut (
        .LOCK(locked),
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .PACKAGEPIN(clock_in),
        .PLLOUTGLOBAL(clock_out)   // 全域時脈輸出
    );
endmodule

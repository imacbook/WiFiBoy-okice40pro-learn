// VGA 輸出層：接收共享時序與像素顏色，輸出 6-bit VGA（enable=0 時黑畫面）
module vga (
    input  pclk,
    input  enable,
    input  [5:0] rgb,       // 2:2:2（r1,r0,g1,g0,b1,b0）
    input  hs, vs,
    output r0, r1, g0, g1, b0, b1,
    output vga_hs, vga_vs,
    output snd
);
    // 打一拍暫存，截斷渲染器的長組合路徑（延遲 1 像素，無感）
    reg [5:0] c = 0;
    always @(posedge pclk) c <= enable ? rgb : 6'b00_00_00;
    assign {r1, r0, g1, g0, b1, b0} = c;
    assign vga_hs = hs;
    assign vga_vs = vs;
    assign snd = 1'b0;
endmodule

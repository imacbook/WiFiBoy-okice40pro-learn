// HDMI 輸出層：接收共享時序與像素顏色，輸出 2:2:1 DVI（SIL164）
// 資料在下降緣暫存 → IDCK(=pclk) 上升緣取樣時已穩定
module hdmi (
    input  pclk,
    input  enable,
    input  [5:0] rgb,       // 2:2:2，取 rgb[5:1]（r1,r0,g1,g0,b1）
    input  hs, vs, de,
    output r0, r1, g0, g1, b1,
    output cl,
    output hdmi_de, hdmi_hs, hdmi_vs
);
    assign cl = pclk;

    reg [4:0] data;
    reg de_r, hs_r, vs_r;
    always @(negedge pclk) begin
        data <= enable ? rgb[5:1] : 5'b00000;
        de_r <= de; hs_r <= hs; vs_r <= vs;
    end

    assign {r1, r0, g1, g0, b1} = data;
    assign hdmi_de = de_r;
    assign hdmi_hs = hs_r;
    assign hdmi_vs = vs_r;
endmodule

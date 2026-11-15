// vga_checker
module vga_checker (
    input  clk12,
    output r0, r1, g0, g1, b0, b1,
    output hs, vs,
    output snd
);
    wire pclk, locked;
    pll pll_i(.clock_in(clk12), .clock_out(pclk), .locked(locked));

    reg [9:0] hcnt = 0, vcnt = 0;
    always @(posedge pclk) begin
        if (hcnt == 10'd799) begin
            hcnt <= 0;
            vcnt <= (vcnt == 10'd524) ? 10'd0 : vcnt + 1;
        end else hcnt <= hcnt + 1;
    end

    wire display = (hcnt < 10'd640) && (vcnt < 10'd480);
    assign hs = ~((hcnt >= 10'd656) && (hcnt < 10'd752));
    assign vs = ~((vcnt >= 10'd490) && (vcnt < 10'd492));

    wire [1:0] R = display ? {2{hcnt[9] ^ vcnt[9]}} : 2'b00;
    wire [1:0] G = display ? {2{hcnt[9] ^ vcnt[9]}} : 2'b00;
    wire [1:0] B = 2'b00;

    assign {r1, r0} = R;
    assign {g1, g0} = G;
    assign {b1, b0} = B;
    assign snd = 1'b0;
endmodule

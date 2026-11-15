// vga_box
module vga_box (
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

    // 方塊位置：每張畫面（VS 結束）移動一次
    reg [9:0] box_x = 10'd200, box_y = 10'd150;
    always @(posedge pclk) begin
        if (hcnt == 10'd799 && vcnt == 10'd524) begin
            box_x <= (box_x >= 10'd600) ? 10'd0 : box_x + 10'd2;
            box_y <= (box_y >= 10'd440) ? 10'd0 : box_y + 10'd1;
        end
    end

    wire in_box = display && (hcnt >= box_x) && (hcnt < box_x + 10'd40)
                            && (vcnt >= box_y) && (vcnt < box_y + 10'd40);

    wire [1:0] R = in_box ? 2'b11 : 2'b00;
    wire [1:0] G = in_box ? 2'b11 : 2'b00;
    wire [1:0] B = in_box ? 2'b11 : 2'b00;

    assign {r1, r0} = R;
    assign {g1, g0} = G;
    assign {b1, b0} = B;
    assign snd = 1'b0;
endmodule

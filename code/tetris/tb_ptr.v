// 驗證：selected=0 時，VGA 指標（index 14）應畫 '>'，HDMI 指標（index 20）應畫 ' '
`timescale 1ns/1ps
module tb_ptr;
    reg clk12 = 0;
    reg selected = 0;
    reg redraw = 0;
    wire sclk, mosi, cs, dc, rst, bl;

    st7735 dut(
        .clk12(clk12), .selected(selected), .redraw(redraw),
        .lcd_sclk(sclk), .lcd_mosi(mosi), .lcd_cs(cs),
        .lcd_dc(dc), .lcd_rst(rst), .lcd_bl(bl)
    );

    always #20 clk12 = ~clk12;  // 25MHz

    reg [2:0] prev_state = 3'd7;
    always @(posedge clk12) begin
        if (dut.state != prev_state) begin
            $display("t=%0t state 0→%0d", $time, dut.state);
            prev_state <= dut.state;
        end
        // 在 S_DRAW 且剛載入字元（dstep==1），列出指標相關的 index
        if (dut.state == 3'd4 && dut.dstep == 5'd1)
            if (dut.tchar == 6'd14 || dut.tchar == 6'd15 || dut.tchar == 6'd20 || dut.tchar == 6'd21)
                $display("  DRAW dstep=1 tchar=%0d dchar=0x%02x('%c')", dut.tchar, dut.dchar, dut.dchar);
    end

    initial begin
        #700_000_000;
        $display("===== done =====");
        $finish;
    end
endmodule

`timescale 1ns/1ps
// ST7735 驅動測試：抓取 SPI 上送出的每個位元組，驗證初始化序列
module tb_st7735;
    reg clk = 0;
    always #41.667 clk = ~clk;   // 12 MHz

    wire lcd_sclk, lcd_mosi, lcd_cs, lcd_dc, lcd_rst, lcd_bl;
    st7735 dut(
        .clk12(clk),
        .lcd_sclk(lcd_sclk), .lcd_mosi(lcd_mosi), .lcd_cs(lcd_cs),
        .lcd_dc(lcd_dc), .lcd_rst(lcd_rst), .lcd_bl(lcd_bl)
    );

    // SPI 抓取：CS 下降緣開始、SCLK 上升緣取 MOSI（MSB first）
    reg prev_sclk = 0, prev_cs = 1;
    reg [7:0] cap_byte;
    reg [2:0] bit_cnt;
    reg cap_active = 0;
    integer nbytes = 0;

    always @(posedge clk) begin
        prev_sclk <= lcd_sclk;
        prev_cs   <= lcd_cs;

        if (prev_cs && !lcd_cs) begin
            cap_active <= 1;
            bit_cnt <= 0;
            cap_byte <= 0;
        end
        if (!prev_sclk && lcd_sclk && cap_active) begin
            if (bit_cnt == 7) begin
                // 第 8 個 bit：組出完整 byte（用舊 cap_byte[6:0] + 現在這個 bit）
                $display("byte[%2d] = 0x%02h  %s", nbytes,
                         {cap_byte[6:0], lcd_mosi},
                         lcd_dc ? "DATA" : "CMD ");
                nbytes <= nbytes + 1;
                cap_active <= 0;
                bit_cnt <= 0;
            end else begin
                cap_byte <= {cap_byte[6:0], lcd_mosi};
                bit_cnt <= bit_cnt + 1;
            end
        end
    end

    initial begin
        // 復位(100ms) + 初始化(360ms) + 填黑(約218ms) 後，開始文字繪製
        #820_000_000;
        $display("===== 共抓取 %0d 位元組 =====", nbytes);
        $finish;
    end
endmodule

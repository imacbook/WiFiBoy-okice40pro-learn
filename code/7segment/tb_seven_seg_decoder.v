`timescale 1ns/1ps
// 7 段解碼器單元測試：餵 0~15，比對段碼
module tb_seven_seg_decoder;
    reg [3:0] digit;
    wire [6:0] seg;
    seven_seg_decoder dut(.digit(digit), .seg(seg));

    reg [6:0] expected;
    reg fail = 0;
    integer i;

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            digit = i[3:0];
            #1;
            case (i)
                0: expected = 7'b1111110;
                1: expected = 7'b0110000;
                2: expected = 7'b1101101;
                3: expected = 7'b1111001;
                4: expected = 7'b0110011;
                5: expected = 7'b1011011;
                6: expected = 7'b1011111;
                7: expected = 7'b1110000;
                8: expected = 7'b1111111;
                9: expected = 7'b1111011;
                default: expected = 7'b0000000;
            endcase
            #1;
            if (seg !== expected) begin
                $display("FAIL digit=%0d seg=%b expected=%b", i, seg, expected);
                fail = 1;
            end else
                $display("OK   digit=%0d seg=%b", i, seg);
        end
        $display(fail ? "==> 有錯誤 ==" : "==> ALL PASS ==");
        $finish;
    end
endmodule

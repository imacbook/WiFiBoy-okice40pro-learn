// step4：六顆各自固定顏色（紅、綠、藍、黃、紫、青）
module rgb_colors (
    input  clk12,
    output r, g, b,
    output d0, d1, d2, d3, d4, d5
);
    // 掃描（約 2kHz/顆，肉眼看不到閃）
    reg [15:0] cnt = 0;
    reg [2:0]  scan = 0;
    always @(posedge clk12) begin
        if (cnt == 16'd5999) begin
            cnt  <= 0;
            scan <= (scan == 5) ? 0 : scan + 1;
        end else
            cnt <= cnt + 1;
    end

    // 每顆的顏色（[2]=R, [1]=G, [0]=B）
    reg [2:0] color;
    always @* begin
        case (scan)
            3'd0: color = 3'b100;  // 紅
            3'd1: color = 3'b010;  // 綠
            3'd2: color = 3'b001;  // 藍
            3'd3: color = 3'b110;  // 黃
            3'd4: color = 3'b101;  // 紫
            3'd5: color = 3'b011;  // 青
            default: color = 3'b000;
        endcase
    end

    // 共陽：0 = 亮
    assign r = ~color[2];
    assign g = ~color[1];
    assign b = ~color[0];

    assign d0 = (scan == 0);
    assign d1 = (scan == 1);
    assign d2 = (scan == 2);
    assign d3 = (scan == 3);
    assign d4 = (scan == 4);
    assign d5 = (scan == 5);
endmodule

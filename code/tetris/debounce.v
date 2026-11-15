// 按鍵去彈跳：輸入需連續穩定 STABLE 個週期才認定，並輸出按下脈衝（0→1）
module debounce #(
    parameter STABLE = 420000   // ~16.7ms @25.125MHz
)(
    input  clk,
    input  btn_in,
    output reg btn_out = 0,     // 去彈跳後的狀態
    output reg btn_press = 0    // 按下脈衝（1 週期）
);
    reg [19:0] cnt = 0;
    reg        stable = 0;

    always @(posedge clk) begin
        btn_press <= 0;
        if (btn_in != stable) begin
            cnt <= cnt + 1;
            if (cnt >= STABLE - 1) begin
                cnt <= 0;
                stable <= btn_in;
                if (btn_in) begin
                    btn_out <= 1;
                    btn_press <= 1;
                end else begin
                    btn_out <= 0;
                end
            end
        end else begin
            cnt <= 0;
        end
    end
endmodule

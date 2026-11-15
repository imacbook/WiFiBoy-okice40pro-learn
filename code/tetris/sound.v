// 音效：方波蜂鳴器（pin 10），不同事件發出不同音高/長度
module sound (
    input  clk,                     // 25.125MHz
    input  move_s, rotate_s,        // 移動/旋轉（短高音）
    input  lock_s, clear_s,         // 鎖定/消行
    input  over_s,                  // Game Over
    output reg speaker = 0
);
    reg [16:0] half = 0;   // 半週期（計數）
    reg [16:0] cnt  = 0;   // 方波相位
    reg [23:0] dur  = 0;   // 持續時間
    reg [23:0] dcnt = 0;   // 持續計數

    always @(posedge clk) begin
        if (over_s) begin
            half <= 17'd69792; dur <= 24'd10050000; cnt <= 0; dcnt <= 0; speaker <= 0;  // 180Hz, 400ms
        end else if (clear_s) begin
            half <= 17'd17946; dur <= 24'd3015000; cnt <= 0; dcnt <= 0; speaker <= 0;  // 700Hz, 120ms
        end else if (lock_s) begin
            half <= 17'd50250; dur <= 24'd1507500; cnt <= 0; dcnt <= 0; speaker <= 0;  // 250Hz, 60ms
        end else if (rotate_s) begin
            half <= 17'd10468; dur <= 24'd628125; cnt <= 0; dcnt <= 0; speaker <= 0;   // 1200Hz, 25ms
        end else if (move_s) begin
            half <= 17'd8375;  dur <= 24'd376875; cnt <= 0; dcnt <= 0; speaker <= 0;   // 1500Hz, 15ms
        end else if (dcnt < dur) begin
            dcnt <= dcnt + 1;
            if (cnt >= half) begin
                cnt <= 0;
                speaker <= ~speaker;
            end else
                cnt <= cnt + 1;
        end else begin
            speaker <= 0;
        end
    end
endmodule

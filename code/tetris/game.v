// 俄羅斯方塊遊戲邏輯：重力、鎖定、消行、重生、計分、關卡加速、結束、重啟、按鍵控制
// 棋盤存於外部 BRAM（20 列 × 16 位元，用前 10 位元）
module game #(
    parameter GRAV_FAST = 25'd2512500    // 軟降重力 ~0.1s
)(
    input  clk,
    input  start,
    input  move_left, move_right,
    input  rotate_cw, rotate_ccw,
    input  soft_drop,
    input  soft_held,
    input  hard_drop,
    input  restart,                     // 重啟（Menu 鍵）
    // BRAM 介面
    input  [15:0] bram_rdata,
    output [4:0]  g_raddr,
    output        g_read,
    output [4:0]  g_waddr,
    output [15:0] g_wdata,
    output        g_we,
    // 給渲染器的目前方塊
    output signed [4:0] piece_x,
    output [4:0] piece_y,
    output [1:0] piece_rot,
    output [2:0] piece_type,
    output       piece_active,
    // 顯示資訊
    output [15:0] score,
    output [2:0]  level,
    output [8:0]  lines,
    output [2:0]  next_type,
    output        game_over,
    output        snd_lock,        // 鎖定音觸發
    output        snd_clear        // 消行音觸發
);
    // ---- spawn 方向：7 種 × 4 格 (x,y) ----
    function [3:0] spawn_xy;
        input [2:0] type; input [1:0] idx;
        reg [1:0] sx, sy;
        begin
            case ({type, idx})
                5'd0:  {sx,sy}={2'd0,2'd1}; 5'd1:  {sx,sy}={2'd1,2'd1};
                5'd2:  {sx,sy}={2'd2,2'd1}; 5'd3:  {sx,sy}={2'd3,2'd1};  // I
                5'd4:  {sx,sy}={2'd1,2'd1}; 5'd5:  {sx,sy}={2'd2,2'd1};
                5'd6:  {sx,sy}={2'd1,2'd2}; 5'd7:  {sx,sy}={2'd2,2'd2};  // O
                5'd8:  {sx,sy}={2'd1,2'd0}; 5'd9:  {sx,sy}={2'd0,2'd1};
                5'd10: {sx,sy}={2'd1,2'd1}; 5'd11: {sx,sy}={2'd2,2'd1};  // T
                5'd12: {sx,sy}={2'd1,2'd0}; 5'd13: {sx,sy}={2'd2,2'd0};
                5'd14: {sx,sy}={2'd0,2'd1}; 5'd15: {sx,sy}={2'd1,2'd1};  // S
                5'd16: {sx,sy}={2'd0,2'd0}; 5'd17: {sx,sy}={2'd1,2'd0};
                5'd18: {sx,sy}={2'd1,2'd1}; 5'd19: {sx,sy}={2'd2,2'd1};  // Z
                5'd20: {sx,sy}={2'd0,2'd0}; 5'd21: {sx,sy}={2'd0,2'd1};
                5'd22: {sx,sy}={2'd1,2'd1}; 5'd23: {sx,sy}={2'd2,2'd1};  // J
                5'd24: {sx,sy}={2'd2,2'd0}; 5'd25: {sx,sy}={2'd0,2'd1};
                5'd26: {sx,sy}={2'd1,2'd1}; 5'd27: {sx,sy}={2'd2,2'd1};  // L
                default: {sx,sy}={2'd0,2'd0};
            endcase
            spawn_xy = {sx, sy};
        end
    endfunction

    function [3:0] block_xy;
        input [2:0] type; input [1:0] rot; input [1:0] idx;
        reg [1:0] sx, sy, rx, ry;
        begin
            {sx,sy} = spawn_xy(type, idx);
            case (rot)
                2'd0: begin rx=sx; ry=sy; end
                2'd1: begin rx=2'd3-sy; ry=sx; end
                2'd2: begin rx=2'd3-sx; ry=2'd3-sy; end
                2'd3: begin rx=sy; ry=2'd3-sx; end
                default: begin rx=sx; ry=sy; end
            endcase
            block_xy = {rx, ry};
        end
    endfunction

    // ---- 重力週期表（依 level）：0.4s ~ 3.0s ----
    function [27:0] grav_period;
        input [2:0] lv;
        begin
            case (lv)
                3'd0: grav_period = 28'd75375000;  // 3.0s
                3'd1: grav_period = 28'd62812500;  // 2.5s
                3'd2: grav_period = 28'd50250000;  // 2.0s
                3'd3: grav_period = 28'd37687500;  // 1.5s
                3'd4: grav_period = 28'd25125000;  // 1.0s
                3'd5: grav_period = 28'd20100000;  // 0.8s
                3'd6: grav_period = 28'd15075000;  // 0.6s
                default: grav_period = 28'd10050000; // 0.4s
            endcase
        end
    endfunction

    // ---- 狀態 ----
    localparam S_FALL  = 3'd0, S_CHECK = 3'd1, S_APPLY = 3'd2,
               S_MERGE = 3'd3, S_CLEAR = 3'd4, S_OVER = 3'd5, S_RST = 3'd6;
    localparam ACT_DOWN = 3'd0, ACT_LEFT = 3'd1, ACT_RIGHT = 3'd2,
               ACT_ROTC = 3'd3, ACT_ROTCC = 3'd4, ACT_SPAWN = 3'd5;

    reg [2:0] state = S_FALL;
    reg [2:0] cur_type = 0;
    reg [1:0] cur_rot  = 0;
    reg signed [4:0] cur_x = 3;
    reg [4:0] cur_y    = 0;
    reg [27:0] gcnt    = 0;
    reg        hard_dropping = 0;

    // 分數/關卡
    reg [15:0] score = 0;
    reg [8:0]  lines = 0;
    reg [2:0]  clear_count = 0;   // 本次消行數（0..4）

    // 檢查參數
    reg signed [4:0] chk_px; reg [4:0] chk_py; reg [1:0] chk_rot; reg [2:0] chk_type;
    reg [2:0] chk_action; reg [1:0] chk_idx; reg chk_phase; reg chk_hit;
    reg [3:0] chk_col_r; reg chk_oob_r;

    // 合併/消行計數
    reg [1:0] merge_idx; reg merge_phase;
    reg [4:0] clear_idx; reg clear_phase; reg [4:0] clear_dst;
    reg [4:0] rst_idx;
    reg snd_lock = 0; reg snd_clear = 0;

    wire [2:0] next_type = (cur_type == 3'd6) ? 3'd0 : cur_type + 3'd1;
    reg  [2:0] next_type_r = 0;
    always @(posedge clk) next_type_r <= next_type;

    // ---- 關卡（依分數門檻）----
    wire [2:0] level = (score >= 16'd25000) ? 3'd7 :
                       (score >= 16'd20000) ? 3'd6 :
                       (score >= 16'd15000) ? 3'd5 :
                       (score >= 16'd10000) ? 3'd4 :
                       (score >= 16'd6000)  ? 3'd3 :
                       (score >= 16'd3000)  ? 3'd2 :
                       (score >= 16'd1000)  ? 3'd1 : 3'd0;

    // ---- 檢查的目前 cell ----
    wire [3:0] chk_b   = block_xy(chk_type, chk_rot, chk_idx);
    wire signed [5:0] chk_ax = chk_px + $signed({4'b0, chk_b[3:2]});
    wire [5:0] chk_ay  = chk_py + chk_b[1:0];
    wire chk_oob = (chk_ax < 6'sd0) || (chk_ax >= 6'sd10) || (chk_ay >= 6'd20);

    // ---- 合併的目前 cell ----
    wire [3:0] mg_b   = block_xy(cur_type, cur_rot, merge_idx);
    wire signed [5:0] mg_ax = cur_x + $signed({4'b0, mg_b[3:2]});
    wire [5:0] mg_ay  = cur_y + mg_b[1:0];
    wire mg_valid = (mg_ax >= 6'sd0) && (mg_ax < 6'sd10) && (mg_ay < 6'd20);

    // ---- 消行的來源列 ----
    wire [4:0] clear_src = 5'd19 - clear_idx;

    // ---- BRAM 讀位址 ----
    wire [4:0] check_raddr = chk_ay[4:0];
    wire [4:0] merge_raddr = mg_ay[4:0];
    assign g_raddr = (state == S_CHECK) ? check_raddr :
                     (state == S_MERGE && !merge_phase) ? merge_raddr :
                     (state == S_CLEAR && !clear_phase) ? clear_src : 5'd0;
    assign g_read  = (state == S_CHECK) ||
                     (state == S_MERGE && !merge_phase) ||
                     (state == S_CLEAR && !clear_phase);

    // ---- BRAM 寫入埠（組合邏輯：讀取後的週期立即寫回）----
    wire merge_wr = (state == S_MERGE && merge_phase == 1'b1 && mg_valid);
    wire clear_wr = (state == S_CLEAR && clear_phase == 1'b1 && bram_rdata[9:0] != 10'h3FF);
    wire rst_wr   = (state == S_RST);
    assign g_we    = merge_wr || clear_wr || rst_wr;
    assign g_waddr = merge_wr ? mg_ay[4:0] : (clear_wr ? clear_dst : rst_idx);
    assign g_wdata = merge_wr ? (bram_rdata | (16'd1 << mg_ax[3:0])) :
                     (clear_wr ? bram_rdata : 16'h0);

    // ---- 計分 ----
    reg [15:0] base_points;
    always @(*) begin
        case (clear_count)
            3'd1: base_points = 16'd100;
            3'd2: base_points = 16'd300;
            3'd3: base_points = 16'd500;
            3'd4: base_points = 16'd800;
            default: base_points = 16'd0;
        endcase
    end
    wire [15:0] score_inc = base_points * {1'b0, level} + base_points;

    wire [27:0] grav_th = soft_held ? GRAV_FAST : grav_period(level);

    // ---- 給渲染器 ----
    assign piece_x = cur_x; assign piece_y = cur_y;
    assign piece_rot = cur_rot; assign piece_type = cur_type;
    assign piece_active = (state == S_FALL) || (state == S_CHECK) || (state == S_APPLY);
    assign game_over = (state == S_OVER);

    always @(posedge clk) begin
        if (!start) begin
            state <= S_FALL;
            cur_type <= 0; cur_rot <= 0; cur_x <= 3; cur_y <= 0;
            gcnt <= 0; hard_dropping <= 0;
            score <= 0; lines <= 0; clear_count <= 0;
            chk_px <= 0; chk_py <= 0; chk_rot <= 0; chk_type <= 0;
            chk_action <= 0; chk_idx <= 0; chk_phase <= 0; chk_hit <= 0;
            chk_col_r <= 0; chk_oob_r <= 0;
            merge_idx <= 0; merge_phase <= 0;
            clear_idx <= 0; clear_phase <= 0; clear_dst <= 0; rst_idx <= 0;
        end else begin
            snd_lock <= 0; snd_clear <= 0;
            case (state)
                S_FALL: begin
                    if (hard_dropping || soft_drop) begin
                        chk_px <= cur_x; chk_py <= cur_y + 5'd1; chk_rot <= cur_rot; chk_type <= cur_type;
                        chk_action <= ACT_DOWN; chk_idx <= 0; chk_phase <= 0; chk_hit <= 0; state <= S_CHECK;
                    end else if (move_left) begin
                        chk_px <= cur_x - 5'sd1; chk_py <= cur_y; chk_rot <= cur_rot; chk_type <= cur_type;
                        chk_action <= ACT_LEFT; chk_idx <= 0; chk_phase <= 0; chk_hit <= 0; state <= S_CHECK;
                    end else if (move_right) begin
                        chk_px <= cur_x + 5'sd1; chk_py <= cur_y; chk_rot <= cur_rot; chk_type <= cur_type;
                        chk_action <= ACT_RIGHT; chk_idx <= 0; chk_phase <= 0; chk_hit <= 0; state <= S_CHECK;
                    end else if (rotate_cw) begin
                        chk_px <= cur_x; chk_py <= cur_y; chk_rot <= cur_rot + 2'd1; chk_type <= cur_type;
                        chk_action <= ACT_ROTC; chk_idx <= 0; chk_phase <= 0; chk_hit <= 0; state <= S_CHECK;
                    end else if (rotate_ccw) begin
                        chk_px <= cur_x; chk_py <= cur_y; chk_rot <= cur_rot - 2'd1; chk_type <= cur_type;
                        chk_action <= ACT_ROTCC; chk_idx <= 0; chk_phase <= 0; chk_hit <= 0; state <= S_CHECK;
                    end else if (gcnt >= grav_th - 1) begin
                        gcnt <= 0;
                        chk_px <= cur_x; chk_py <= cur_y + 5'd1; chk_rot <= cur_rot; chk_type <= cur_type;
                        chk_action <= ACT_DOWN; chk_idx <= 0; chk_phase <= 0; chk_hit <= 0; state <= S_CHECK;
                    end else
                        gcnt <= gcnt + 1;
                end

                S_CHECK: begin
                    if (chk_phase == 0) begin
                        chk_col_r <= chk_ax[3:0]; chk_oob_r <= chk_oob;
                        chk_phase <= 1;
                    end else begin
                        chk_hit <= chk_hit | (chk_oob_r || bram_rdata[chk_col_r]);
                        chk_phase <= 0;
                        if (chk_idx == 2'd3) state <= S_APPLY;
                        else chk_idx <= chk_idx + 2'd1;
                    end
                end

                S_APPLY: begin
                    case (chk_action)
                        ACT_DOWN: begin
                            if (!chk_hit) begin cur_y <= cur_y + 5'd1; state <= S_FALL; end
                            else begin hard_dropping <= 0; merge_idx <= 0; merge_phase <= 0; snd_lock <= 1; state <= S_MERGE; end
                        end
                        ACT_LEFT: begin
                            if (!chk_hit) cur_x <= cur_x - 5'sd1;
                            state <= S_FALL;
                        end
                        ACT_RIGHT: begin
                            if (!chk_hit) cur_x <= cur_x + 5'sd1;
                            state <= S_FALL;
                        end
                        ACT_ROTC: begin
                            if (!chk_hit) cur_rot <= cur_rot + 2'd1;
                            state <= S_FALL;
                        end
                        ACT_ROTCC: begin
                            if (!chk_hit) cur_rot <= cur_rot - 2'd1;
                            state <= S_FALL;
                        end
                        default: begin  // ACT_SPAWN
                            if (chk_hit) state <= S_OVER;
                            else begin
                                cur_type <= next_type_r; cur_rot <= 2'd0; cur_x <= 5'sd3; cur_y <= 5'd0;
                                state <= S_FALL;
                            end
                        end
                    endcase
                end

                S_MERGE: begin
                    if (merge_phase == 0) begin
                        merge_phase <= 1;
                    end else begin
                        merge_phase <= 0;
                        if (merge_idx == 2'd3) begin
                            state <= S_CLEAR;
                            clear_idx <= 0; clear_phase <= 0; clear_dst <= 5'd19; clear_count <= 0;
                        end else
                            merge_idx <= merge_idx + 2'd1;
                    end
                end

                S_CLEAR: begin
                    if (clear_phase == 0) begin
                        clear_phase <= 1;
                    end else begin
                        if (bram_rdata[9:0] == 10'h3FF)
                            clear_count <= clear_count + 3'd1;   // 滿列
                        else
                            clear_dst <= clear_dst - 5'd1;
                        clear_phase <= 0;
                        if (clear_idx == 5'd19) begin
                            // 消行完成 → 計分 + 重生檢查
                            score <= score + score_inc;
                            lines <= lines + {6'd0, clear_count};
                            if (clear_count != 3'd0) snd_clear <= 1;
                            chk_px <= 5'sd3; chk_py <= 5'd0; chk_rot <= 2'd0; chk_type <= next_type_r;
                            chk_action <= ACT_SPAWN; chk_idx <= 0; chk_phase <= 0; chk_hit <= 0;
                            state <= S_CHECK;
                        end else
                            clear_idx <= clear_idx + 5'd1;
                    end
                end

                S_OVER: begin
                    if (restart) begin
                        state <= S_RST; rst_idx <= 0;
                    end
                end

                S_RST: begin
                    // 寫 0 到 row rst_idx（組合邏輯 rst_wr 已處理）
                    if (rst_idx == 5'd19) begin
                        // 重啟完成
                        cur_type <= 0; cur_rot <= 0; cur_x <= 3; cur_y <= 0;
                        gcnt <= 0; hard_dropping <= 0;
                        score <= 0; lines <= 0; clear_count <= 0;
                        state <= S_FALL;
                    end else
                        rst_idx <= rst_idx + 5'd1;
                end
            endcase
        end
    end
endmodule

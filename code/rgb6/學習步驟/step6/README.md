# step6：呼吸燈（PWM）

## 目的
用 PWM（快速開關）做出「漸亮漸暗」的效果。

## 原理
- 人眼有視覺暫留，快速開關時看到的是「平均亮度」。
- 開的時間比例（duty cycle）越高 → 看起來越亮。

## 程式碼
```verilog
wire on = (pwm_cnt[7:0] < bright);   // duty cycle = bright / 256
assign r = ~on;                     // 共陽：0 = 亮
```
- `bright` 從 0 慢慢加到 255，再降回 0
- `pwm_cnt[7:0]` 每秒循環 256 次，跟 `bright` 比較

## 執行
```bash
cd step6
make
make prog
```

## 應該看到
第 0 顆紅燈慢慢變亮、再慢慢變暗（呼吸效果）。

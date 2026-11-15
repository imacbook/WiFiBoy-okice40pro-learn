# step2：兩顆 LED（紅 + 綠）

## 目的
送出 48 bit，讓前兩顆 LED 亮不同顏色。

## 關鍵
- 每顆 24 bit，第 0 顆先送、第 1 顆後送。
- 第 0 顆收到 24 bit 後會把後面的資料「轉送」給第 1 顆（串接）。
- 送完所有資料後拉低 1200 週期，兩顆同時更新。

## 程式碼
```verilog
case (idx)
    0: color_of = 24'h00FF00;  // 紅（GRB）
    1: color_of = 24'hFF0000;  // 綠（GRB）
endcase
```
- `NUM_LEDS = 2`，`led_cnt` 從 0 送到 1

## 執行
```bash
cd step2
make
make prog
```

## 應該看到
第 0 顆紅、第 1 顆綠。

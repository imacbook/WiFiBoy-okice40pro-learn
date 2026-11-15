# step1：一顆紅色

## 目的
送出一顆 LED 的 24 bit，讓第 0 顆亮紅。

## WS2812B 協定
- 每顆 LED 24 bit，順序是 **GRB**（不是 RGB！）
- 紅色 = R:255, G:0, B:0 → **GRB = 00 FF 00** → `24'h00FF00`
- 每個 bit 15 個 12MHz 週期（1.25µs）：
  - `0`：高 5、低 10
  - `1`：高 10、低 5
- 送完要拉低 **1200 週期**（reset/latch），LED 才會更新

## 程式碼
```verilog
localparam T0H = 5, T1H = 10;
din <= (cyc < (shift[23] ? T1H : T0H)) ? 1'b1 : 1'b0;
```
- `shift[23]` 是目前要送的 bit
- 若是 1 → 高 10 週期；若是 0 → 高 5 週期

## 執行
```bash
cd step1
make
make prog
```

## 應該看到
第 0 顆 LED 亮紅色。

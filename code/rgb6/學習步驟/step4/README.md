# step4：六顆各自不同顏色

## 目的
每顆 LED 有自己的顏色，靠「快速掃描」讓它們同時亮。

## 關鍵
- 6 顆 LED 共用 3 條色線，所以**同一時間只能顯示一種顏色**。
- 解法：一次只開一顆，快速輪流（約 2kHz/顆），靠視覺暫留看起來同時亮。

## 程式碼
```verilog
case (scan)
    3'd0: color = 3'b100;  // 紅
    3'd1: color = 3'b010;  // 綠
    ...
endcase
assign r = ~color[2];   // 共陽：0 = 亮
```
- `scan` 每 6000 個 clk 換一顆（12MHz/6000 = 2kHz）
- 每顆的顏色存在 `color` 裡

## 執行
```bash
cd step4
make
make prog
```

## 應該看到
6 顆 LED 分別是紅、綠、藍、黃、紫、青。

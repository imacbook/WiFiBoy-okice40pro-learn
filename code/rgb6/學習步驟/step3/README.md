# step3：六顆輪流掃描

## 目的
確認 6 條選線（D0~D5）各對應哪一顆 LED。

## 程式碼
```verilog
assign d0 = (scan == 0);
assign d1 = (scan == 1);
...
assign d5 = (scan == 5);
```
- `scan` 0~5 每秒 +1
- 同一時間只有一條選線是 1 → 只有一顆 LED 亮

## 執行
```bash
cd step3
make
make prog
```

## 應該看到
6 顆 LED 每秒輪流亮一顆（白光）。

## 學到
這是「矩陣掃描」的基本功：一次只開一顆，快速輪流。

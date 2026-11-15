# step2：三色輪流

## 目的
讓同一顆 LED 輪流顯示紅、綠、藍。

## 程式碼
```verilog
if (cnt == 24'd11_999_999) begin
    cnt  <= 0;
    step <= (step == 2) ? 0 : step + 1;   // 0→1→2→0
end

assign r = (step == 0) ? 1'b0 : 1'b1;
assign g = (step == 1) ? 1'b0 : 1'b1;
assign b = (step == 2) ? 1'b0 : 1'b1;
```
- `cnt` 數 1200 萬次 = 1 秒
- `step` 0/1/2 對應 R/G/B

## 執行
```bash
cd step2
make
make prog
```

## 應該看到
第 0 顆 LED 每秒換色：紅 → 綠 → 藍 → 紅…

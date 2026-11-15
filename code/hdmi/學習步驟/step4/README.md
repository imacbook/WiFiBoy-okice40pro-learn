# step4：2:2:1 彩色漸層

## 目的
用 5-bit 色（2:2:1）畫出彩色漸層。

## 程式碼
```verilog
wire [1:0] R = display ? hcnt[8:7] : 2'b00;
wire [1:0] G = display ? vcnt[8:7] : 2'b00;
wire       B = display ? (hcnt[8] ^ vcnt[8]) : 1'b0;
```
- R 隨水平、G 隨垂直、B 是 XOR（只有 1 bit，所以只有亮/暗）

## 應該看到
彩色漸層（B 只有 1 bit，所以藍色變化比較少）。

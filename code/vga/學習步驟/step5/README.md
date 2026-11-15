# step5：漸層

## 目的
用 6-bit 色（R/G/B 各 2 bit）畫出漸層。

## 程式碼
```verilog
wire [1:0] R = display ? hcnt[8:7] : 2'b00;
wire [1:0] G = display ? vcnt[8:7] : 2'b00;
wire [1:0] B = display ? (hcnt[8:7] ^ vcnt[8:7]) : 2'b00;
```
- R 隨水平變化、G 隨垂直變化、B 是兩者 XOR
- 6-bit 色 = R/G/B 各 2 位元 = 64 色

## 應該看到
彩色漸層畫面。

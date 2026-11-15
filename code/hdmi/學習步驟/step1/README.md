# step1：同步訊號（黑畫面）

## 目的
先讓 HDMI 螢幕「有訊號」，確認 CL / DE / HS / VS 時序正確。

## HDMI 的 9 個腳位

| PMOD | 訊號 | 作用 |
|------|------|------|
| p1 | R1 | 紅色（2 bit 的高位）|
| p2 | R0 | 紅色（低位）|
| p3 | G1 | 綠色（高位）|
| p4 | G0 | 綠色（低位）|
| p5 | B1 | 藍色（只有 1 bit！）|
| p6 | CL | 像素時脈（IDCK）|
| p7 | DE | Data Enable（可視區）|
| p8 | HS | 水平同步 |
| p9 | VS | 垂直同步 |

## DVI/HDMI 原理
- FPGA 輸出的是**並列**的 R/G/B + CL + DE + HS/VS。
- SIL164（DVI 發射器）把這些並列訊號轉成 **TMDS**（過渡最小化差動訊號）。
- 所以 FPGA 不需要自己產生 TMDS，只要送對「並列資料 + 時脈」。

## 程式碼
```verilog
assign cl = pclk;          // 輸出像素時脈
assign de = display;       // 可視區
assign hs = ~((hcnt >= 656) && (hcnt < 752));
assign vs = ~((vcnt >= 490) && (vcnt < 492));
```

## 執行
```bash
cd step1
make
make prog
```

## 應該看到
HDMI 螢幕出現全黑畫面（有訊號）。

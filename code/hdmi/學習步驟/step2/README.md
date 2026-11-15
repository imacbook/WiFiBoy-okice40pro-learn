# step2：DE（Data Enable）

## 目的
搞懂 DE 的作用：只有 DE=1 的區域才是「可視區」。

## 什麼是 DE
- **DE = Data Enable**：告訴 SIL164「現在這個像素要顯示」。
- DE=1 的區域 = 640×480 可視區。
- DE=0 的區域 = 消隱區（不顯示）。

## 程式碼
```verilog
assign de = display;   // display = (hcnt<640) && (vcnt<480)
wire [1:0] R = display ? 2'b11 : 2'b00;   // 可視區塗紅
```

## 應該看到
整個畫面是紅色（可視區），消隱區不影響。

## 顯示原理
DE 讓發射器知道「哪些像素要送出去」，比只靠 HS/VS 更精確。

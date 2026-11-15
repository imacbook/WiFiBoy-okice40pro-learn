# step6：移動方塊（動畫）

## 目的
用 HDMI 輸出一個會移動的方塊。

## 程式碼
```verilog
if (hcnt == 799 && vcnt == 524) begin   // 每張畫面
    box_x <= box_x + 2;
    box_y <= box_y + 1;
end
wire in_box = display && (hcnt >= box_x) && (hcnt < box_x+40) && ...;
```

## 應該看到
一個白色方塊在 HDMI 螢幕上移動。

## 顯示原理
與 VGA 相同：每個畫面（60Hz）更新一次 → 動畫。

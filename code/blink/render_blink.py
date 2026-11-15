#!/usr/bin/env python3
# 把 blink_sim.vcd 解析並渲染成兩張數位波形圖（時間單位：VCD 為 ps）
import re
from PIL import Image, ImageDraw, ImageFont

VCD = "blink_sim.vcd"
text = open(VCD, encoding="utf-8", errors="ignore").read()

# ---- 解析 $var 宣告：id -> (名稱, 位寬) ----
id_info = {}
for m in re.finditer(r'\$var\s+\w+\s+(\d+)\s+(\S+)\s+([^\s\[]+?)(?:\s+\[[^\]]*\])?\s+\$end', text):
    id_info[m.group(2)] = (m.group(3), int(m.group(1)))

def id_of(name):
    for idc, (n, w) in id_info.items():
        if n == name:
            return idc
    return None

id_clk = id_of('clk12')
id_cnt = id_of('counter')
id_ledr = id_of('led_r')
id_ledb = id_of('led_b')
assert all(x is not None for x in (id_clk, id_cnt, id_ledr, id_ledb)), "找不到需要的訊號"

# ---- 解析 value change ----
body = text.split('$enddefinitions $end', 1)[1]
scalar = {}   # id -> [(t, 0/1), ...]
vector = {}   # id -> [(t, valstr), ...]
cur_time = 0
i, n = 0, len(body)
while i < n:
    c = body[i]
    if c == '#':
        j = i + 1
        while j < n and body[j].isdigit():
            j += 1
        cur_time = int(body[i+1:j])
        i = j
    elif c == '$':
        j = body.find('\n', i)
        i = n if j == -1 else j
    elif c == 'b':
        m = re.match(r'b([01xzXZ]+)\s+(\S)', body[i:])
        if m:
            vector.setdefault(m.group(2), []).append((cur_time, m.group(1)))
            i += m.end()
        else:
            i += 1
    elif c in '01xzXZ':
        m = re.match(r'([01xzXZ])(\S)', body[i:])
        if m:
            v = 1 if m.group(1) == '1' else 0
            scalar.setdefault(m.group(2), []).append((cur_time, v))
            i += m.end()
        else:
            i += 1
    else:
        i += 1

# ---- 取 counter 的某個 bit 作為 time series ----
def bit_series(vec_id, width, bit):
    out = []
    last = 0
    for (t, valstr) in vector.get(vec_id, []):
        if valstr in ('x', 'X'):
            v = 0
        else:
            v = (int(valstr, 2) >> bit) & 1
        if v != last:
            out.append((t, v))
            last = v
    return out

cnt_width = id_info[id_cnt][1]
clk = scalar.get(id_clk, [])
ledr = scalar.get(id_ledr, [])
ledb = scalar.get(id_ledb, [])
c0 = bit_series(id_cnt, cnt_width, 0)
c1 = bit_series(id_cnt, cnt_width, 1)
c2 = bit_series(id_cnt, cnt_width, 2)
c3 = bit_series(id_cnt, cnt_width, 3)

# ---- 渲染 ----
FONT = ImageFont.load_default()

def render(traces, t0, t1, outpath, title):
    W, H = 1500, 60 + 46 * len(traces)
    img = Image.new("RGB", (W, H), "white")
    d = ImageDraw.Draw(img)
    LM, RM, TM = 150, 30, 40
    plot_x0, plot_x1 = LM, W - RM
    def tx(t):
        return plot_x0 + (plot_x1 - plot_x0) * (t - t0) / (t1 - t0)

    d.text((12, 10), title, fill="black", font=FONT)

    for idx, (name, trans) in enumerate(traces):
        y_top = TM + idx * 46 + 8
        y_bot = y_top + 30
        d.text((10, y_top + 8), name, fill="black", font=FONT)
        def y_of(v):
            return y_top if v else y_bot
        cur = 0
        for (t, v) in trans:
            if t <= t0:
                cur = v
            else:
                break
        px, py = tx(t0), y_of(cur)
        pts = [(px, py)]
        for (t, v) in trans:
            if t <= t0:
                continue
            if t > t1:
                break
            x, y = tx(t), y_of(v)
            pts.append((x, py))
            pts.append((x, y))
            px, py = x, y
        pts.append((tx(t1), py))
        d.line(pts, fill="#1f77b4", width=2)

    for k in range(5):
        t = t0 + (t1 - t0) * k / 4
        x = tx(t)
        d.line([(x, H - 30), (x, H - 22)], fill="black", width=1)
        if t1 >= 1e9:
            lbl = f"{t/1e9:.2f}ms"
        elif t1 >= 1e6:
            lbl = f"{t/1e6:.2f}us"
        elif t1 >= 1e3:
            lbl = f"{t/1e3:.0f}ns"
        else:
            lbl = f"{t:.0f}ps"
        d.text((x - 14, H - 20), lbl, fill="black", font=FONT)

    img.save(outpath)
    print("已輸出", outpath)

# Panel 1：放大前 1 us，看時脈與 counter 低位元
render(
    [("clk12", clk), ("counter[0]", c0), ("counter[1]", c1),
     ("counter[2]", c2), ("counter[3]", c3)],
    0, 1_000_000, "blink_wave_zoom.png",
    "05-blink 模擬波形（放大 0~1us：時脈與 counter 低位元，每個 bit 頻率除以 2）"
)

# Panel 2：完整 6.5 ms，看 LED 輸出
render(
    [("led_r", ledr), ("led_b", ledb)],
    0, 6_500_000_000, "blink_wave_full.png",
    "05-blink 模擬波形（完整 0~6.5ms：led_r 約每 1.365ms 翻轉；led_b 需 ~0.7s 才翻轉，此窗格為 0）"
)

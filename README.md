# 7 段顯示器學習動畫（網站版）

純靜態網站，可直接放 GitHub Pages / 任何靜態主機。

## 檔案
- `index.html`：入口首頁（9 個步驟卡片）
- `step1.html` ~ `step9.html`：各步驟動畫
- `img/`：卡片縮圖
- `.nojekyll`：GitHub Pages 用（避免 Jekyll 處理）

## 本機預覽
直接用瀏覽器開 `index.html` 即可。

## 部署到 GitHub Pages
1. 把整個 `web/` 資料夾內容推到 repo（例如 `docs/` 或根目錄）
2. GitHub repo → Settings → Pages
3. Source 選「Deploy from a branch」，資料夾選你放的位置
4. 網址：`https://<帳號>.github.io/<repo>/`

> 建議用 `web/` 當資料夾名稱，或改名 `docs/`（GitHub Pages 支援從 `/docs` 發布）。

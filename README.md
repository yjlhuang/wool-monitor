# 🐑 wool-monitor

> Claude 流量計＋薅羊毛儀表板。本機執行、免錢、零執行期依賴、可常駐桌面置頂浮窗。
>
> Fork 自 [danleetw/ai_usage_dashboard](https://github.com/danleetw/ai_usage_dashboard)，
> 原作是通用的多提供商 AI 用量儀表板（電玩血條風格），本 fork 改造成「Claude 單推」版本：
> 一眼看 Session / Weekly / Fable 三條血條，加上一張佛系的 Fable 燒錢估算表。
> 錢都花下去了，當然要薅好薅滿——客家美學。🐑

## 功能（相對原作的差異）

- **Fable 每週配額條**：解析 `oauth/usage` 新版 `limits[]` 陣列，模型別配額（如 Fable）自動長出對應血條；
  上游哪天拿掉這個 window，血條就自動消失，不用改程式。
- **撞牆預警**:任一條用量 ≥90% 時發 **Windows 原生系統通知**（PowerShell toast，零依賴），
  每條血條每個重置週期只通知一次。血條色階:≥70% 黃、≥85% 橘、≥92% 紅。
- **🐑 Fable 薅羊毛進度表**（可摺疊，預設收起）：掃描本機 `~/.claude/projects/*.jsonl`，
  篩出 Fable 訊息、按 message id 去重（session 續接不重複計費）、cache token 全算，
  換算成 API 等值美金。顯示已燒/剩餘、近 7 日速度、預估耗盡日 vs 訂閱到期日（😌/🚨）。
  額度、起算日、到期日皆可在 UI 設定。增量掃描＋快取（`wool-cache.json`），700MB log 首掃約 5 秒。
- **版面精簡**：Claude 置頂常駐；Codex / Antigravity 收進「📦 其他提供商」摺疊區
  （浮窗模式不顯示）；MiniMax / Kiro 預設移除（可從「＋ 新增提供商」加回）。
- **浮窗修正**：顯示縮放 ≠100%（如 125%）時的 DPI 定位 bug 修正（原本會把浮窗放到螢幕外變隱形）；
  `.bat` 改為背景啟動，不留 cmd 視窗。

### 定價假設（佛系粗估）

| 項目 | USD / 1M tokens |
|---|---|
| input | $10 |
| output | $50 |
| cache 讀 | $1 |
| cache 寫（5 分鐘） | $12.5 |
| cache 寫（1 小時） | $20 |

只計本機 Claude Code log（多帳號混計），**不含 claude.ai 網頁端用量**（本機沒有 log）。
這是心裡有底用的估算，不是帳單。

## 快速開始

需要 [Node.js](https://nodejs.org/)（LTS 即可）。

- **瀏覽器完整版**：雙擊 `start.bat`，開 http://127.0.0.1:3789
- **置頂浮窗**（Windows）：雙擊 `floating-widget.bat`（伺服器沒在跑會自動拉起）。
  按住空白處拖曳搬移、拖邊角調大小、**Alt+F4 關閉**。
- **迷你單行版**：雙擊 `floating-widget-mini.bat`，↑/↓ 切換提供商。

浮窗需要 WebView2 SDK 的 3 顆 DLL（約 900KB，微軟官方 NuGet，不隨版控發佈），第一次請在專案根目錄執行：

```powershell
Invoke-WebRequest -Uri "https://api.nuget.org/v3-flatcontainer/microsoft.web.webview2/1.0.4022.49/microsoft.web.webview2.1.0.4022.49.nupkg" -OutFile webview2.zip
Expand-Archive webview2.zip -DestinationPath webview2_tmp
New-Item -ItemType Directory -Force floating-widget-lib
Copy-Item webview2_tmp\lib\net462\Microsoft.Web.WebView2.Core.dll, webview2_tmp\lib\net462\Microsoft.Web.WebView2.Wpf.dll, webview2_tmp\runtimes\win-x64\native\WebView2Loader.dll floating-widget-lib\
Remove-Item webview2.zip, webview2_tmp -Recurse
```

## 安全

- OAuth token 只在本機後端讀取（`~/.claude/.credentials.json`），**絕不進前端、絕不外送**。
- 伺服器只綁 `127.0.0.1:3789`。
- `config.json`（個人設定）、`wool-cache.json`(含本機路徑)、`server.log` 都在 `.gitignore`，不會被 commit。
- 用量端點是非公開 API，可能隨時改版；所有解析都 graceful 失敗、沿用舊資料。

## Credit 與授權

本專案大量沿用 [danleetw/ai_usage_dashboard](https://github.com/danleetw/ai_usage_dashboard)
的程式碼（`server.js` / `index.html` / `floating-widget.ps1` 的整體架構與實作），感謝原作者 🙏。
原專案截至 fork 時未標示授權條款；本 fork 以致敬與個人自用為目的公開，
若原作者對此有任何意見，請開 issue，會立即配合處理。
本 fork 新增的部分（薅羊毛精算、limits[] 解析、通知等）以 MIT 授權釋出。

進度與待辦見 [PROGRESS.md](PROGRESS.md)，最初的規格見 [施工單.md](施工單.md)。

# 🐑 wool-monitor

> Claude 流量計＋薅羊毛儀表板。本機執行、免錢、零執行期依賴、可常駐桌面置頂浮窗。
>
> Fork 自 [danleetw/ai_usage_dashboard](https://github.com/danleetw/ai_usage_dashboard)，
> 原作是通用的多提供商 AI 用量儀表板（電玩血條風格），本 fork 改造成「Claude 為主」的版本：
> 一眼看 Session / Weekly 血條，加上一張佛系的「訂閱月費回本倍率」估算表。
> 另可同時盯 Codex 與 Antigravity 的配額。
> 錢都花下去了，當然要薅好薅滿——客家美學。🐑

## 功能（相對原作的差異）

- **模型別配額條（動態長出）**：解析 `oauth/usage` 新版 `limits[]` 陣列，
  上游回報什麼模型別／群組配額，就自動長出對應血條；拿掉就自動消失，不用改程式。
  （歷史上這是為了 Fable 週配額做的。**Claude Pro 現在已不含 Fable**，
  所以 Claude 卡目前不會有額外血條——這是預期，不是壞掉。
  同一套機制現在撐的是 Antigravity 的第二桶配額，見下。）
- **撞牆預警**:任一條用量到 **90% / 95%** 時各發一次 **Windows 原生系統通知**
  （PowerShell toast，零依賴），之後不再吵；用量掉回 85% 以下（視窗重置）才重新警戒。
  血條色階:≥70% 黃、≥85% 橘、≥92% 紅。
- **🐑 薅羊毛進度表**（預設展開）：掃描本機 `~/.claude/projects/*.jsonl`，
  **不限模型全算**（Fable / Opus / Sonnet / Haiku…，每則按自己那顆模型的 API 牌價）、
  按 message id 去重（session 續接不重複計費）、cache token 全算，
  換算成 API 等值金額並以**台幣顯示**（匯率可在表單調，預設 30；內部計價與月費欄位仍為 USD）。
  **基準是訂閱月費**（Claude Pro 預設 US$20）：算「這個帳單週期薅回幾倍」，
  血條 100% = 回本，超過就直接顯示倍率。另有本期模型別小計、近 7 日速度、
  期末預估、以及累計回本倍率（總燒 ÷ 總共付過的月費）。
  月費、匯率、訂閱起始日（決定帳單週期是每月幾號）皆可在 UI 設定。
  增量掃描＋快取（`wool-cache.json`），700MB log 首掃約 5 秒。
- **Antigravity（Google 的 agentic IDE）配額**：無公開 usage API，改打它自己在
  `127.0.0.1` 開的 Connect-RPC 本機服務。**需要 Antigravity IDE 開著**
  （token 是 IDE 啟動時現產的，關掉就失效）——只在終端機跑 `agy` 是不夠的。
  會顯示兩條週配額：`Gemini Models`（Flash / Pro）與 `Claude and GPT models`
  （Opus / Sonnet / GPT-OSS，Google 代付的第三方額度）。
  **後者跟你自己的 Claude Pro 訂閱無關，也不會被薅羊毛表重複計算**
  （那張表只掃本機 Claude Code 的 jsonl）。
  Antigravity 只有週配額，沒有 session 級或 context 資料，那幾格直接不顯示。
- **版面精簡**：Claude 置頂常駐；其餘提供商收進「📦 其他提供商」區
  （**預設展開**，手動收起會被記住；浮窗模式一律不顯示）；
  MiniMax / Kiro 預設移除（可從「＋ 新增提供商」加回）。
- **浮窗修正**：顯示縮放 ≠100%（如 125%）時的 DPI 定位 bug 修正（原本會把浮窗放到螢幕外變隱形）；
  `.bat` 改為背景啟動，不留 cmd 視窗。

### 定價假設（佛系粗估）

每則訊息按**自己那顆模型**的第一方 API 牌價換算（USD / 1M tokens）：

| 模型 | input | output |
|---|---|---|
| Fable 5 / Mythos 5 | $10 | $50 |
| Opus 5 / 4.8 / 4.7 / 4.6 / 4.5 | $5 | $25 |
| 舊世代 Opus（4.1 / 4.0 / 3） | $15 | $75 |
| Sonnet 5 / 4.6 / 4.5 / 4 | $3 | $15 |
| Haiku 4.5 | $1 | $5 |
| Haiku 3.5 | $0.8 | $4 |
| Haiku 3 | $0.25 | $1.25 |
| 認不得的新模型 | $5 | $25（當 Opus 級估） |

cache 一律由 input 推導：**讀 0.1×、寫 5 分鐘 1.25×、寫 1 小時 2×**
（Fable 換算下來就是舊版的 $1 / $12.5 / $20，數字沒變，只是改成通用公式）。
沒有 5m/1h 細分的舊 log，整包當 5 分鐘 cache 算（寧可低估）。
Sonnet 5 目前有 $2/$10 促銷價，這裡一律取牌價 $3/$15（寧可高估）。

只計本機 Claude Code log（多帳號混計、不限模型），**不含 claude.ai 網頁端用量**（本機沒有 log）。
這是心裡有底用的估算，不是帳單——它回答的是「同樣這些活兒，改打 API 要付多少」，
拿來跟訂閱月費比，就是回本倍率。

## 快速開始

需要 [Node.js](https://nodejs.org/)（LTS 即可）。

- **瀏覽器完整版**：雙擊 `start.bat`，開 http://127.0.0.1:3789
- **置頂浮窗**（Windows）：雙擊 `floating-widget.bat`（伺服器沒在跑會自動拉起）。
  按住空白處拖曳搬移、拖邊角調大小、控制列 **✖**（或 Alt+F4）關閉。
  浮窗開著時再次執行 `floating-widget.bat` 會自動取代舊的（不會疊兩個）。
  預設緊湊版面（字級不縮、間距縮，約原尺寸 88% 密度；`-Scale 0.85` 可再疊 zoom 縮更小，但字會稍糊）；
  滑鼠移入浮窗右下角有控制列：
  ◐ 滑桿調平常的卡片背景透明度、🖱 滑桿調滑鼠移入時的透明度、
  👻 滑鼠穿透（點擊直接穿過浮窗到下層視窗；開啟後浮窗點不到，按 **Ctrl+Alt+W** 切回）、
  ⏴ 收納到螢幕右緣（滑鼠靠右緣的小把手就滑出、離開又收回，📌 取消收納；
  空白處**雙擊**也能切換收納）、✖ 關閉浮窗（伺服器照跑）。
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
- Antigravity 的 CSRF token 從本機行程表（`language_server.exe` 的啟動參數）讀取，
  只留在記憶體、只用來打 `127.0.0.1`，**不寫檔、不印出、不回傳前端**。
- 用量端點是非公開 API，可能隨時改版；所有解析都 graceful 失敗、沿用舊資料。

## Credit 與授權

本專案大量沿用 [danleetw/ai_usage_dashboard](https://github.com/danleetw/ai_usage_dashboard)
的程式碼（`server.js` / `index.html` / `floating-widget.ps1` 的整體架構與實作），感謝原作者 🙏。
原專案截至 fork 時未標示授權條款；本 fork 以致敬與個人自用為目的公開，
若原作者對此有任何意見，請開 issue，會立即配合處理。
本 fork 新增的部分（薅羊毛精算、limits[] 解析、通知等）以 MIT 授權釋出。

**不想讀技術細節?看 [使用指南.md](使用指南.md)（小白流,含每顆按鈕在幹嘛）。**
進度與待辦見 [PROGRESS.md](PROGRESS.md)（也是給下一個 LLM 的交接文件），
人話版的進度與展望見 [docs/進度與展望.md](docs/進度與展望.md)，
最初的規格見 [施工單.md](施工單.md)（**歷史文件，多數前提已作廢**）。

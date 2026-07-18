# 進度筆記

> 給下一個 session（或另一個帳號的 Claude）接手用的狀態快照。
> 讀完這份＋README 就能繼續，不用重新考古。

## 目前版本:wool-v0.4(2026-07-19)

### 已完成

- **v0.1 流量警報器**
  - `fetchClaude()` 優先解析 `oauth/usage` 的 `limits[]` 陣列（2026-07 新版格式；
    `kind: session / weekly_all / weekly_scoped`，Fable 藏在 weekly_scoped 的
    `scope.model.display_name`）。舊頂層欄位（`five_hour`/`seven_day`）留作 fallback。
    模型別配額動態渲染成附加血條，上游消失就自動不顯示。
  - 色階 70 黃 / 85 橘（新增 `.fill.o`）/ 92 紅。
  - ≥90% 發 Windows toast（`server.js` 的 `sysNotify`/`checkClaudeAlerts`），
    每條 bar 每個 `resets_at` 週期只叫一次。
    ⚠️ 技術坑:PowerShell 腳本必須用 `-EncodedCommand`(UTF-16LE base64)傳,
    `-Command` 會把 XML 屬性引號吃掉。
- **v0.2 🐑 薅羊毛表**
  - `scanFableFile`/`rescanWool`/`woolSummary`(server.js):增量掃 jsonl
    （mtime+size 判斷）、`"claude-fable` 字串預篩、message id 全域去重、
    cache 5m/1h 分開計價。快取 `wool-cache.json`（gitignore）。
  - API:`GET /api/wool`、`POST /api/wool/config`（budgetUsd/startDate/expiryDate
    → `config.json` 的 `wool` 鍵）。
  - 前端可摺疊區塊＋金色進度條＋設定表單，5 分鐘輪詢（掃描中 8 秒重試）。
- **v0.3 版面精簡**:MiniMax/Kiro 一次性移除（`seedBuiltins` 的 `purgedUnused` 旗標，
  可從＋加回）；非 claude 提供商收進 `#minorBox` 摺疊區（開合狀態跨重繪保留）。
- **v0.4 浮窗修復**
  - 補齊 WebView2 DLL（fork 缺 `floating-widget-lib/` 也缺 `ensure-webview2.ps1`）。
  - **DPI bug 修正**:主人螢幕 1920×1080 @125%（邏輯 1536×864），
    上游拿 WinForms WorkingArea（實體 px）餵 WPF Left（邏輯單位），浮窗被放到
    螢幕外變隱形。已在 `floating-widget.ps1` 加 DPI 換算。
  - 兩支 `.bat` 改 `start`+`-WindowStyle Hidden`，不留 cmd 陪跑。
  - 浮窗模式 `.minor` 直接 `display:none`（主人只要 Claude）。

### 主人已裁決的事(不要重新問)

- cache token 全算（施工單原本只寫 input/output，會低估到失真）。
- 額度預設 $10（贈送 credit），起算日/到期日 UI 可填可留空——主人自己也還不確定
  日期（雙帳號、其一誤訂），留空時顯示全歷史總量。
- 路 B（sniff claude.ai credit endpoint）跳過。
- 通知門檻 90%、輪詢/退避沿用原作,不改短。

## 待辦(主人 2026-07-19 口頭 backlog)

1. **浮窗透明度調整**——現在 widget-mode 卡片是固定半透明,想要可調
   （參數化 rgba alpha?加 URL 參數或 UI 滑桿）。
2. **區塊調小**——浮窗裡的卡片/字級再緊湊一點。
3. **收進側邊**——浮窗可以 dock 到螢幕側邊收起來、滑鼠靠近再滑出（auto-hide）。
   會動到 `floating-widget.ps1` 的原生視窗邏輯。
4. Antigravity:主人是**教育版 Pro**，可能根本查不到配額（教育版網頁也不顯示用量）。
   等主人跑 `agy` 實測,若查不到把錯誤文案改誠實一點（「教育版不提供用量資訊」）。
5. （遠期）帳號切換:施工單的擴充位,雙帳號各自快照。

## 執行/測試備忘

- 開伺服器:`start.bat` 或 `node server.js`（port 3789，只綁 127.0.0.1）。
- 浮窗:`floating-widget.bat`（Alt+F4 關）。DLL 抓法見 README。
- 驗證 API:`GET /api/usage`（Claude 含 extra=Fable）、`GET /api/wool`。
- 頁面右上有版本號 `wool-vX.Y`（`index.html` 的 `#verTag`），改版記得升,
  部署疑義一眼裁決。
- 上游 repo:https://github.com/danleetw/ai_usage_dashboard（**無 LICENSE**，
  README 的 credit 段已寫明立場）。

# 進度筆記

> 給下一個 session（或另一個帳號的 Claude）接手用的狀態快照。
> 讀完這份＋README 就能繼續，不用重新考古。

## 目前版本:wool-v0.8(2026-08-11)

### v0.8 內容:分母換成「Pro 月費」,語意翻轉

主人是 **Claude Pro 訂閱戶**(US$20/月),v0.7 之後的「額度 $20 一桶 credit」前提整個失效
(算全模型後直接爆表變「完美榨乾」,毫無資訊量)。這版把整張表的語意翻過來:
**不是「一桶錢燒到乾」,是「這期付的月費薅回幾倍」**——燒越多越賺,血條衝滿是好事。

- **設定欄位**:`budgetUsd`/`expiryDate` → `monthlyFeeUsd`(預設 20)+ `startDate`(訂閱起始日)。
  `woolConfig()` 讀不到 `monthlyFeeUsd` 時會**沿用舊的 `budgetUsd` 當月費**(不用手動改檔);
  存檔時才把兩個舊鍵刪掉。到期日整個拿掉——訂閱是每月續約,沒有「到期前燒不完」這回事。
- **帳單週期 `billingCycle()`**:以訂閱起始日的「日」當錨點算出本期 [start, nextCharge)。
  月底錨點(29〜31)遇短月夾到當月最後一天;第一期不會早於訂閱起始日本身。
  沒設起始日就退回自然月。
- **`/api/wool` 回傳改版**:拿掉 `budgetUsd`/`remainingUsd`/`daysLeft`/`depleteDate`/`expiryDate`,
  改回 `monthlyFeeUsd`、`cycle{start,nextCharge,days,elapsed,usd,roi,projectedUsd,projectedRoi}`、
  `cyclesPaid`/`paidUsd`/`lifetimeRoi`。`totalUsd` 維持累計(訂閱起始日之後)。
- **`models[]` 與 `msgCount` 改成只算本期**(和標題數字對得起來);`totalUsd` 仍是累計,
  由「累計 … = N 倍」那行單獨呈現。⚠️ 模型別各自四捨五入,加總可能和 `cycle.usd` 差 1 分錢。
- **前端**:血條 100% = 回本(超過顯示「回本 N 倍」而非壓在 100%),
  新增本期區間/第幾天、期末預估、累計回本倍率;表單三欄(月費/匯率/訂閱起始日)。
- 實測(2026-08-11,本期第 11/31 天):本期 **回本 21.9 倍**、期末預估 61.9 倍;
  累計回本 43.2 倍。(絕對金額不入版控,要對數字自己開 dashboard 看)

## 前一版:wool-v0.7(2026-08-11)

### v0.7 內容

- **薅羊毛不再只算 Fable(主人指定:Pro 方案已不含 Fable)**:
  `scanFableFile` → `scanWoolFile`,字串預篩從 `"claude-fable` 放寬成 `"claude-`
  (順帶濾掉 `<synthetic>` 那種非模型訊息),model 前綴檢查同步放寬。
- **改成模型別計價**:同一條公式、不同單價。新增 `WOOL_MODEL_PRICE`
  (regex → [input, output],由上往下第一個命中為準,所以新世代 Opus 要排在泛用
  Opus 之前),cache 全部由 input 推導:讀 0.1×、寫 5m 1.25×、寫 1h 2×
  ——代進 Fable 的 $10 剛好還原舊版寫死的 $1/$12.5/$20,舊數字沒被改動。
  認不得的新模型 fallback 當 Opus 級($5/$25)。
  ⚠️ 拿 Fable 的 $10/$50 去算 Opus/Sonnet 會嚴重高估,所以不是「全部套同一組價」。
- **快取版本號 `WOOL_CACHE_VER`**:計價規則改了但 jsonl 的 mtime/size 沒變,
  舊快取會被沿用 → 顯示舊價。加 `v` 欄位,版本不合就整包重掃(這次已重掃過)。
  快取列從 `[id, date, usd]` 變成 `[id, date, usd, model]`,並在**檔內先去重**
  (一則訊息的每個 content block 各佔一行,usage 會重複寫;舊版靠全域 Map 覆蓋
  才沒重複計費,但快取檔被灌成 483KB)。
- **模型別小計**:`/api/wool` 多回 `models: [{model, usd, msgs}]`(依金額排序,
  和 `totalUsd` 同一個起算日過濾條件),前端 stats 多一行「模型別:opus-5 NT$… ·
  fable-5 NT$…」(只列前 4 名,其餘併成「…」)。
- **`msgCount` 語意修正**:原本回 `byId.size`(全歷史),但 `totalUsd` 是起算日之後的,
  兩個數字對不起來(實測差了三倍以上)。改成只數計入金額的訊息;
  `firstDate` 維持全歷史最早日(留著讓主人挑起算日)。

## 前一版:wool-v0.6(2026-07-19)

### v0.6 內容

- **👻 穿透關不掉的 bug(主人回報:Ctrl+Alt+W 關閉後整個浮窗消失/凍住,必須重開)**:
  根因是 WebView2 樹裡有幾個視窗**原生就帶 `WS_EX_TRANSPARENT`**(WPF 的 HwndHost
  「Static」、`Chrome_RenderWidgetHostHWND`、`Intermediate D3D Window`——後兩者屬於
  msedgewebview2.exe,不是我們的程序),v0.5 的 SetGhost(off) 對「所有」子視窗一律
  清 bit,把人家原生的也剝掉 → 實測(styles dump + 截圖)浮窗停止渲染、位置凍住、
  收納失靈,再按快捷鍵(ghost:on 把 bit 塞回去)才會重新出現但點不到。
  修法:ghost:on 只對「本來沒有這個 bit」的視窗加 bit 並記進 `_ghosted` 清單,
  ghost:off 只還原清單裡的——原生 bit 永不碰,開關往返 = 真正的 no-op。
- **單一實例防護**:重複啟動 floating-widget 會疊出兩個浮窗,且 RegisterHotKey
  同鍵只有最早的實例搶得到,Ctrl+Alt+W 會切到「看不見的舊實例」──株連前一條 bug
  一起發作時症狀更詭異。現在 ps1 啟動時先 FindWindow 舊浮窗:WM_CLOSE 禮貌接手,
  4 秒沒反應(舊實例凍死)就強制結束。⚠️ FindWindow 必須包在 C# 裡呼叫,
  PowerShell 會把 $null 塞成空字串害它永遠找不到(踩過)。
- **✖ 關閉浮窗按鈕**(主人許願):控制列新增 ✖,頁面 post `close` → 宿主 Close()
  (等同 Alt+F4)。伺服器照跑;瀏覽器開 ?widget=1 時按了是 no-op(預期)。
- **90% 通知轟炸修正**(主人回報:到 90% 後 toast 反覆跳,關掉 Claude Code 也在跳):
  toast 其實是本專案 node 伺服器發的(借 PowerShell 的 AppId,通知來源顯示
  PowerShell),跟 Claude Code 無關。反覆跳的根因:上游 `oauth/usage` **每次請求
  都重新生成 resets_at(連微秒尾碼都在變)**,拿它當「同週期只叫一次」的 key
  每輪詢都變新週期。改成門檻階梯:90%/95% 各通知一次(95 文案更急),
  用量掉回 85 以下(視窗重置)才重新警戒。不再依賴 resets_at。

## 前一版:wool-v0.5(2026-07-19)

### v0.5 內容

- **is_active 對齊修正**:`oauth/usage` 的 `limits[]` 每條有 `is_active` 欄位;
  false 時(claude.ai 顯示 "Starts when a message is sent")`resets_at` 只是會隨輪詢
  漂移的佔位值,不能當倒數渲染(主人截圖抓到每週重生 7/22 vs 實際 API 隔幾小時變 7/26)。
  `fetchClaude()` 現在把 `isActive` 傳給前端,inactive 的重生格顯示「未啟動/發訊息後起算」。
- **CONTEXT 條澄清**(非 bug):那是本機 `scanClaudeContext()` 掃「30 分鐘內活躍的
  Claude Code session」的 context window 佔用(tokens/200k),label 是該 session 的 cwd
  資料夾名,跟 claude.ai 網頁的配額無關、也不跟「目前在看的專案」對齊。
- **浮窗三件套**(主人 backlog 1–3):
  - 尺寸:先做了 `-Scale` CSS zoom(0.67→0.8),主人反應**字發糊**(125% DPI 下
    非整數字級的宿命),改成 **widget 模式緊湊樣式**:字級維持整數 px、只縮
    padding/間距/血條高度(≈88% 密度),`-Scale` 保留(預設 1)可再疊 zoom。
    zoom 只能掛 `#rows/#woolBox` 區塊——掛 root 會把 top-layer `<dialog>` 的置中算壞。
  - 透明度滑桿(◐):widget 模式卡片背景 rgba 的 alpha 走 `--card-alpha` CSS 變數,
    右下角 hover 控制列調整,存 localStorage(`woolWidgetAlpha`)。
  - 右側收納(⏴/📌):頁面 postMessage `dock:on/off` 給 ps1;C# 端游標輪詢 timer
    (200ms,WebView2 吞滑鼠事件所以不能用 MouseEnter),收起時只留 14px 發光小把手,
    游標貼右緣滑出、離開 1.2s 收回。狀態存 localStorage(`woolWidgetDock`),跨啟動還原。
- **dialog 置中修正**:頂部 `* { margin:0 }` reset 吃掉 UA 的 `dialog { margin:auto }`,
  編輯視窗其實一直貼在左上角——補 `margin:auto` 回 dialog 規則。
- **widget 顏色調亮**(主人指定):黃色 .22 alpha 是亮度基準,綠/紅調到 .45、橘 .3;
  標籤與「已用 x%」副標改成跟血條白字同色(含 text-shadow)。
- **widget 減法**(主人 2026-07-19 追加):▲▼ 排序鍵藏掉(單卡無意義)、
  薅羊毛區預設展開(但**視窗高度維持一張卡**,羊毛在捲動區裡展開——主人明確不要
  視窗變高)、羊毛區文字同步調白。
- **血條亮度最終定案**:widget 模式填色不再壓 alpha,直接用一般模式的全亮漸層
  (比照薅羊毛金條;含倒數條)。只剩軌道(空的部分)維持半透明。
- **雙擊收納**:浮窗空白處雙擊=切換收納(宿主偵測 450ms 內兩次 drag 訊息,
  回傳 toggleDock 給頁面走按鈕同一條路,狀態才會同步)。
- **瀏覽器完整版**:字體放大調亮(`html:not(.widget-mode)` 範圍:標籤 13px、
  副標 12px、羊毛 stats 14px,顏色從 muted 改 --text)。主人瀏覽器的語言
  localStorage(`aiDash.lang.v1`)已代設回 zh-Hant。
- **hover 透明度**:卡片背景透明度分兩段(◐ 平常/🖱 滑鼠移入),CSS 變數鏈
  `--ca ← :hover ? --card-alpha-hover : --card-alpha`,hover 沒調過就跟隨平常值。
- **👻 滑鼠穿透**:WS_EX_TRANSPARENT 要同時掛在頂層＋EnumChildWindows 的所有
  WebView2 子視窗(只掛頂層沒用,Chromium 子 HWND 自己收滑鼠)。開啟後浮窗
  完全點不到,唯一出口是宿主 RegisterHotKey 的 **Ctrl+Alt+W**;快捷鍵切換會
  PostWebMessageAsString('ghostState:*') 回頁面同步按鈕/localStorage。
- **薅羊毛表**:標題拿掉「Fable」(實際上算的是整個 Claude 家族的本機用量);
  金額顯示轉台幣 `NT$`(匯率欄位新增於表單,預設 30,存 `config.json` 的
  `wool.twdRate`;內部計價與額度欄位仍是 USD)。

## 前一版:wool-v0.4(2026-07-19)

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
    ※ v0.7 已改名 `scanWoolFile` 並放寬成不限模型、模型別計價,見上方 v0.7 段。
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
- 薅羊毛**不限模型**(2026-08-11 主人指定,Pro 方案已不含 Fable):Sonnet / Opus /
  Fable 全算,每則按自己模型的 API 牌價,不是全部套 Fable 的 $10/$50。
- **主人是 Claude Pro 訂閱戶(US$20/月)**,薅羊毛的分母是**月費**、單位是**回本倍率**,
  不是「一桶 credit 燒到乾」(2026-08-11 主人指定)。血條衝滿=好事,不要當警戒條處理。
- ~~額度預設 $10（贈送 credit），起算日/到期日 UI 可填可留空——主人自己也還不確定
  日期（雙帳號、其一誤訂），留空時顯示全歷史總量。~~
  **已作廢(v0.8)**:改成 Pro 月費基準,額度/到期日欄位已移除,起始日改當帳單週期錨點。
- 路 B（sniff claude.ai credit endpoint）跳過。
- 通知門檻 90%、輪詢/退避沿用原作,不改短。

## 待辦

1. ~~浮窗透明度調整~~ ~~區塊調小~~ ~~收進側邊~~ → v0.5 完成。
2. Antigravity:主人是**教育版 Pro**，可能根本查不到配額（教育版網頁也不顯示用量）。
   等主人跑 `agy` 實測,若查不到把錯誤文案改誠實一點（「教育版不提供用量資訊」）。
3. （遠期）帳號切換:施工單的擴充位,雙帳號各自快照。

## 執行/測試備忘

- 開伺服器:`start.bat` 或 `node server.js`（port 3789，只綁 127.0.0.1）。
- 浮窗:`floating-widget.bat`（Alt+F4 關）。DLL 抓法見 README。
- 驗證 API:`GET /api/usage`（Claude 含 extra=Fable）、`GET /api/wool`。
- 頁面右上有版本號 `wool-vX.Y`（`index.html` 的 `#verTag`），改版記得升,
  部署疑義一眼裁決。
- 上游 repo:https://github.com/danleetw/ai_usage_dashboard（**無 LICENSE**，
  README 的 credit 段已寫明立場）。

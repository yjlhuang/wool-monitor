# 進度筆記 / 交接文件

> 給下一個 session（或另一個帳號的 Claude）接手用。假設你是**全新開機、零上下文**。
> 讀完這份就能繼續，不用重新考古。

---

## 🚀 開工必讀（照順序）

1. `~/.claude/CLAUDE.md`（使用者的全域偏好；含繁體中文、比例原則、vault 橋接）
2. **本檔**（狀態快照、地雷區、已裁決事項）
3. [README.md](README.md)（功能與設計決策）
4. 需要時才讀：[使用指南.md](使用指南.md)（操作面）、
   [docs/進度與展望.md](docs/進度與展望.md)（人話版進度）、
   [施工單.md](施工單.md)（**歷史文件，多數前提已作廢，別照著做**）

## 📌 一句話定位

**本機執行的 AI 用量儀表板**：盯 Claude / Codex / Antigravity 的配額血條，
外加一張「訂閱月費回本倍率」的佛系估算表（🐑 薅羊毛）。

技術形態：

- **零執行期依賴**。Node 內建模組 + 單檔前端。`playwright` 只是 devDependency，常駐不需要。
- **沒有 build step**。改 `index.html` / `server.js` 存檔、重啟 server 就生效。
- **沒有部署**。純本機，`node server.js` 只綁 `127.0.0.1:3789`。**不要找 Vercel/線上版，沒有這種東西。**
- 桌面浮窗是 WPF + WebView2（`floating-widget.ps1`），載入同一個頁面的 `?widget=1`。

## 📸 狀態快照（2026-09-17）

| 項目 | 值 |
|---|---|
| 工作目錄版本 | **wool-v0.9**（`index.html` 的 `#verTag`） |
| 最新 commit | 見 `git log -1`（v0.9 發版 commit） |
| 未提交檔案 | 無（發版時一併 commit） |
| Claude 自動同步 | 🔴 **失敗中** — 本機憑證 2026-09-16 23:13 過期（見待辦 1） |
| Codex 自動同步 | 🟢 正常 |
| Antigravity 自動同步 | 🟢 正常（前提：IDE 開著） |
| MiniMax / Kiro | 預設已移除，可從「＋新增提供商」加回 |

## 💣 地雷區（這個專案特有，踩過才知道）

1. **`resets_at` 每次請求都重生**（微秒尾碼都在變）。**永遠不要拿它當週期 key**，
   否則通知會重複觸發或永不觸發。
2. **`limits[]` 的 `is_active: false`** 時 `resets_at` 是漂移佔位值
   （claude.ai 顯示 "Starts when a message is sent"），不能渲染成倒數。
3. **快取存的是 token 數（v4 起），改價格只要改 `WOOL_MODEL_PRICE`，不用升版、不用重掃。**
   `WOOL_CACHE_VER` 只在「記錄欄位格式」改變時 +1。**不要為了改價格升版**：版本不合會整包丟棄快取，
   而 Claude Code 預設約 30 天就清掉舊 jsonl，丟掉的紀錄無法從磁碟還原（2026-10-14 已因此遺失 7–9 月紀錄）。
   已消失的 jsonl 紀錄現在會保留在快取裡，不再被刪除。
4. **Antigravity 的 token 是 IDE 現產的**，IDE 關掉就失效。`agy.exe` 的命令列是空的，
   拿不到 token；**能問到數字的只有 IDE 那支 `language_server.exe`**。
5. **PowerShell 腳本含巢狀引號一律走 `-EncodedCommand`**（base64 UTF-16LE）。
   `-Command` 會被 cmd/PowerShell 兩層跳脫吃掉字元（toast 的 XML 引號踩過一次，
   `Get-CimInstance -Filter` 又踩過一次）。
6. **`execSync` 呼叫 PowerShell 要加 `stdio: ['ignore','pipe','ignore']`**，
   否則 CLIXML progress 會噴進伺服器 console。
7. **WebView2 樹裡有些子視窗原生自帶 `WS_EX_TRANSPARENT`**。滑鼠穿透關閉時
   一律清 bit 會把浮窗弄到不渲染＋凍住；只能還原「自己加過的那些」。
8. **使用者的 PowerShell 指令若含 `floating-widget` 字串**，`Get-CimInstance` 過濾會匹配到自己，
   要排除 `$PID`（踩過：把自己 kill 掉 exit 255）。
9. **螢幕是 1920×1080 @ 125% 縮放**（邏輯 1536×864）。WinForms 的 WorkingArea 是實體 px，
   直接餵 WPF 的 Left（邏輯單位）會把浮窗定位到螢幕外變隱形。
10. **CSS `zoom` 只能掛 `#rows` / `#woolBox`**，掛 root 會弄壞 dialog 置中。
11. **編輯檔案時注意編碼**：用腳本改檔一律明確指定 UTF-8，繁體中文不要混進簡體字。
12. **UI state 只能有一個權威寫入者**。多個事件來源搶寫同一格會導致高亮亂跳且極難 debug。
13. **上游端點全是非公開 API**，隨時可能改格式或改驗證方式（v0.8.1 修的 Antigravity 就是）。
    所有解析都要 graceful 失敗、沿用舊資料，不可整個崩掉。

## 🗣️ 使用者的偏好與溝通方式

- **一律繁體中文**。看得懂英文，但預設用中文。
- **比例原則**：低風險（文件、註解、明顯的單點修正）直接做完再回報，不要開顧問會議；
  高風險（不可逆、對外、動到使用者看得到的行為）才走完整驗證。
- **回報「完成」前要在瀏覽器實際驗證最終渲染結果**，不是只看程式碼。沒驗的就照實說沒驗。
- **只有明講才 commit**。不要自作主張存檔或推上去。
- 測試用的 stub / 假資料 / debug log **測完必須移除**，絕不可留進 commit。
- 改版記得升 `#verTag` 的版本號。

## ➡️ 接手後建議的第一步

先看「待辦」第 1 項（Claude 憑證過期）——那是儀表板最核心的功能目前處於降級狀態。
其次是把 v0.8.1 這批未提交的改動存檔。

---

# 版本沿革

## 目前版本:wool-v0.9(2026-10-14)

- **薅羊毛計價改依官方價目表**（commit `27d5e07`）：
  - cache 讀取價每個模型各自計價（Fable 5.1 $0.25、Opus 5.5 $0.20、Sonnet 5.5 $0.10、Haiku 5.5 $0.01）。
  - 新增 Opus 5.5（$4/$20）、Sonnet 5.5（$2/$10）、Haiku 5.5（$0.10/$0.50，prompt 超過 10 萬 token 改用 $0.50/$2.50）。
  - 修正 `claude-sonnet-5`（$2/$10，原誤用 $3/$15）、拆開 Fable 5.1 與 Fable 5（後者 cache 讀取 $1）。
  - 改價後與舊表相比，全部日誌的總額差 −US$547（舊表 1,279.78 → 新表 732.64）。
- **快取改存 token 數**（`WOOL_CACHE_VER` 4）：美元在查詢時換算，改價格不再需要升版或重掃。
- **已消失的日誌紀錄保留**：Claude Code 預設約 30 天清掉舊 jsonl，之前掃過的花費不再隨之消失。
- ⚠️ **已知事故**：v0.9 之前把快取版本升到 3 時，舊快取整包被丟棄，**2026-07〜09 月的累計紀錄已無法從磁碟還原**。目前累計回本倍率（9.2 倍）仍低估，要等日誌保留期拉長或時間累積後才會接近真實值。
- 驗證：獨立重算（直接掃 jsonl）與 `/api/wool` 的 totalUsd 比對 732.64 vs 732.63；頁面上薅羊毛區本期金額與回本倍率與 API 一致。

## 前一版:wool-v0.8.1(2026-09-17)

### v0.8.1 內容:Antigravity 改走 IDE 的 language_server

**症狀**:Antigravity 卡在「未偵測到執行中的 agy CLI」/ 查詢失敗,讀不到任何數字。

**原因**:v0.4 那套「agy CLI 的本機 Connect-RPC 不需要 CSRF token」的前提**已經過期**。
實測 2026-09-17,agy CLI(9233)和 Antigravity IDE 的 language_server(8843)兩邊都回
`401 {"code":"unauthenticated","message":"missing CSRF token"}`。

**修法**:
- token 在 `language_server.exe` 的啟動參數 `--csrf_token` 裡(Antigravity 主行程每次啟動
  用 `crypto.randomUUID()` 現產,關掉 IDE 就失效),header 名稱是 **`x-codeium-csrf-token`**
  (Antigravity 的 LS 沿用 Codeium 的實作;從 `resources/bin/language_server.exe` 裡撈到字串)。
- `findAgyListenPorts()` → **`findAgyEndpoints()`**,回傳 `[{ port, csrf }]`:
  用 `Get-CimInstance Win32_Process` 抓 `agy.exe` / `language_server.exe` 的完整命令列
  (**wmic 在新版 Windows 已移除,不要用**),再用 netstat 把 pid 對回 127.0.0.1 的 LISTENING port。
  **token 只跟自己那個 pid 的 port 配對**,不可跨行程混用。
- `language_server.exe` 也可能是 Windsurf/Codeium 外掛的,所以只收命令列含 `antigravity` 的那支。
- PowerShell 腳本含巢狀引號,一律走 `-EncodedCommand`(base64 UTF-16LE);
  `execSync` 加 `stdio:['ignore','pipe','ignore']`,否則 PowerShell 的 CLIXML progress
  會噴進伺服器 console。
- **`agy.exe` 自己的命令列是空的,拿不到 token**,所以實際問得到數字的是 IDE 那支。
  兩者共用同一個 Google 帳號配額,所以**開著 Antigravity IDE 就夠了,不必另外開終端機跑 agy**。
  錯誤文案已跟著改(不再叫使用者去終端機跑 agy)。

**同批附帶改動(2026-09-17)**:
- `PROVIDER_CACHE_MS = { antigravity: 20000 }`：`cachedFetch()` 改成可按 provider 給不同快取壽命。
  預設 `CACHE_MS`（3 分）是為了不撞官方端點限流，但 antigravity 走的是 127.0.0.1 本機 RPC，
  沒限流問題，快取 3 分鐘會跟 IDE 自己顯示的數字對不起來，改 20s 跟前端輪詢（60s）同步。
- 前端 `minorOpen` 預設改成 **true**（主人開始用別家了），並存進 localStorage `aiDash.minorOpen.v1`；
  手動收起會被記得。浮窗不受影響（`.widget-mode .minor` 是 `display:none`）。

- **不支援的欄位直接不渲染**(主人 2026-09-17 裁決)：Antigravity 卡上「目前使用率／
  下次重生／CONTEXT」三格不再畫「無法讀取」占位。區分標準：
  - session：上游回 `session: null` = 明講沒這種資料 → `sess.unsupported` → 不畫。
  - context：伺服器只幫 claude/codex 掛 `context` 陣列（server.js:1130-1131）。
    **根本沒這個欄位 = 不支援（不畫）；有陣列但是空的 = 支援但無活躍 session（仍顯示無法讀取）**。
    改這塊前先確認 Codex 的 CONTEXT 欄沒被誤殺。
- 圈起來的 `Claude and GPT models` extra bar **主人裁決留著**：那是 Antigravity 自己的
  第二桶配額（bucketId `3p-weekly`，Google 代付的第三方模型），**跟主人自己的 Claude Pro
  訂閱無關、也不會跟薝羊毛表重複計算**（薝羊毛表只掃本機 Claude Code 的 jsonl）。
  在 Antigravity 裡切成 Claude/GPT 模型時這條才會動。

**實測結果**(2026-09-17,IDE 開著):
```
groups[0] Gemini Models          remainingFraction 0.543 → 已用 45.7%,週重生 9/24
groups[1] Claude and GPT models  remainingFraction 1     → 已用  0.0%(當 extra bar)
```
→ 待辦 2 的「教育版查不到配額」疑慮**排除**,查得到。

**注意**:
- 兩個 bucket 的 `resetTime` 各自不同,而且每次請求都會漂(滾動視窗),
  跟 Claude `limits[]` 的 `is_active:false` 佔位值一樣**不要拿來當週期 key**。
- **IDE 剛啟動時 language server 可能先回一份 `remainingFraction: 1` 的快取(卡片顯示 0%)**,
  過一陣子才變成真實數字——不是 bug，不用追。
- IDE 關掉 → token 消失 → 這張卡會退回「未偵測到」,這是預期行為。
- `normalizeAntigravityQuota()` 只取「第一個非 Gemini group」當 extra;目前上游就兩組,
  未來若多出第三組會被靜靜丟掉,屆時要改成 map 全部 groups。

## 前一版:wool-v0.8(2026-08-11)

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

### 1. 🔴 Claude 憑證過期,自動同步降級中（**待老師裁決**）

2026-09-17 實測:`~/.claude/.credentials.json` 的 `claudeAiOauth.expiresAt` 是
**2026-09-16 23:13**,已過期 → `fetchClaude()` 在 server.js:200 直接回 `CLAUDE_TOKEN_EXPIRED`,
Claude 卡退回手動值。薅羊毛表不受影響(掃本機 log,不需要授權)。

**尚未查證**的部分:該檔案該由誰刷新。目前錯誤文案寫「執行任一 claude 指令讓它自動刷新」,
那是針對 CLI 版寫的;老師現在用桌面版,**是否也會刷新同一個檔案沒有驗證過**,不要當成事實。

三個方向(都還沒做):

1. 不改程式,過期時手動跑一次 CLI 版刷新。
2. 用檔案裡的 refresh token 自動續期——**會動到授權流程,風險較高,必須老師點頭**。
3. 只改文案,不要斷言「跑 claude 指令就會好」。

### 2. v0.8.1 尚未 commit

`server.js`、`index.html`、`PROGRESS.md`、`README.md`、`使用指南.md`、`施工單.md`、
`docs/進度與展望.md` 都還在工作目錄。老師說了才 commit。

### 3. `normalizeAntigravityQuota()` 只吃兩組 group

上游目前剛好兩組(Gemini / Claude+GPT),正常。多出第三組會被**靜靜丟掉且不報錯**。
等真的發生再改成 map 全部 groups。

### 4. （遠期）帳號切換

施工單的擴充位,雙帳號各自快照。目前薅羊毛表是多帳號混計。

### ✅ 已關閉

- ~~浮窗透明度調整 / 區塊調小 / 收進側邊~~ → v0.5 完成。
- ~~Antigravity 教育版可能查不到配額~~ → 2026-09-17 實測查得到。
- ~~「Antigravity 數字對不上」~~ → 2026-09-17 老師回報後確認可以了。
  過程中排除了一個可能成因(本機 RPC 卻套 3 分鐘快取,已改 20 秒),
  但**實際成因未查明**,再發生需重新調查。

## 執行/測試備忘

- 開伺服器:`start.bat` 或 `node server.js`（port 3789，只綁 127.0.0.1）。
- 浮窗:`floating-widget.bat`（Alt+F4 關）。DLL 抓法見 README。
- 驗證 API:`GET /api/usage`、`GET /api/wool`。
  `usage` 的 `providers.<id>.extra[]` 是動態模型別/群組配額
  （Claude 目前無；Antigravity 有 `Claude and GPT models`）。
- 驗證 Antigravity 要先確認 IDE 開著;快取 20s（`PROVIDER_CACHE_MS`）。
- 頁面右上有版本號 `wool-vX.Y`（`index.html` 的 `#verTag`），改版記得升,
  部署疑義一眼裁決。
- 上游 repo:https://github.com/danleetw/ai_usage_dashboard（**無 LICENSE**，
  README 的 credit 段已寫明立場）。

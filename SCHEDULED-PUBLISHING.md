# 定時發佈文章系統

## 概述

該系統允許七兄提前編寫文章，指定發佈時間，系統將自動在指定時刻發佈到網站。

## 文件說明

### 1. `scheduled-articles.json` - 待發佈文章隊列

存儲所有待發佈與已發佈的文章。

**格式：**
```json
{
  "scheduled_articles": [
    {
      "publish_time": "2026-03-01 09:00",
      "title": "文章標題",
      "category": "分類",
      "figures": ["人物1", "人物2"],
      "content": "<div class='card'>...</div>",
      "status": "scheduled"
    }
  ],
  "published_articles": [...]
}
```

**欄位說明：**
- `publish_time`: 發佈時間（格式：`YYYY-MM-DD HH:MM` UTC）
- `title`: 文章標題
- `category`: 分類
- `figures`: 人物列表
- `content`: HTML 內容
- `status`: 狀態（`scheduled` 或 `published`）

### 2. `check-and-publish.sh` - 定時檢查腳本

每小時由 Cron 執行，檢查是否有文章達到發佈時間。

**工作流程：**
1. 讀取 `scheduled-articles.json`
2. 檢查當前時間 vs 發佈時間
3. 若到達發佈時間：
   - 添加文章到 `index.html`
   - 更新 `scheduled-articles.json` 狀態為 `published`
   - Git commit + push
   - GitHub Pages 自動同步

### 3. `setup-cron.sh` - Cron 管理工具

設置、移除、測試 Cron 任務。

## 使用步驟

### 步驟 1: 添加待發佈文章

編輯 `scheduled-articles.json`，在 `scheduled_articles` 陣列中添加：

```json
{
  "publish_time": "2026-03-01 14:30",
  "title": "未來的文章",
  "category": "現代數學",
  "figures": ["高斯", "歐拉"],
  "content": "<div class='card'><h3>🔍 標題</h3><p>內容...</p></div>",
  "status": "scheduled"
}
```

**時間格式重要！** 必須是 UTC 時間。

### 步驟 2: 安裝 Cron 任務

```bash
cd /home/node/.openclaw/workspace/math-history
bash setup-cron.sh install
```

### 步驟 3: 驗證安裝

```bash
bash setup-cron.sh status
```

輸出應顯示：
```
✅ 已安裝
排程：
0 * * * * bash /home/node/.openclaw/workspace/math-history/check-and-publish.sh >> /tmp/cron-publish.log 2>&1
```

## 例子

### 例子 1: 明天上午 9 點發佈

```bash
# 編輯 scheduled-articles.json
# publish_time 設為 "2026-03-01 09:00"
```

系統將在 2026-03-01 09:00 UTC 檢查，若符合，自動發佈。

### 例子 2: 一週內每天發佈一篇

```json
{
  "scheduled_articles": [
    {"publish_time": "2026-03-02 09:00", "title": "第一篇", ...},
    {"publish_time": "2026-03-03 09:00", "title": "第二篇", ...},
    {"publish_time": "2026-03-04 09:00", "title": "第三篇", ...}
  ]
}
```

Cron 將每小時檢查一次，達到時間就發佈。

## 檢查日誌

```bash
# 實時監控發佈日誌
tail -f /tmp/scheduled-deploy.log

# 查看 Cron 執行日誌
tail -f /tmp/cron-publish.log
```

## 常見問題

### Q: 文章沒有在指定時間發佈？

A: 檢查：
1. 時間格式是否正確（`YYYY-MM-DD HH:MM`）
2. 時區是否為 UTC
3. Cron 任務是否安裝（`bash setup-cron.sh status`）
4. 日誌中是否有錯誤

### Q: 如何移除 Cron 任務？

A: `bash setup-cron.sh remove`

### Q: 可否手動測試發佈流程？

A: `bash setup-cron.sh test`

## 技術細節

- **檢查間隔**：每小時整點（0 分）
- **時間來源**：系統 UTC 時間
- **自動化**：Git commit + push（GitHub Pages 自動部署）
- **日誌**：`/tmp/scheduled-deploy.log` 與 `/tmp/cron-publish.log`

## 未來改進

- [ ] 添加發佈前通知
- [ ] 支持 JSON 批量導入
- [ ] Web UI 管理界面
- [ ] 自動備份舊版本

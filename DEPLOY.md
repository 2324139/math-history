# 環境配置

## 部署信息

**GitHub Pages URL:** https://2324139.github.io/math-history/

## 自動部署

使用方式：

### 1. 一次性部署（將 index.html 推送至 GitHub Pages）
```bash
export GITHUB_TOKEN="YOUR_TOKEN_HERE"  # 從環境變數或 ~/.github/token 讀取
cd /home/node/.openclaw/workspace/math-history
bash deploy-gp.sh
```

### 2. 持續監控與自動部署（後台運行）
```bash
nohup bash watch-gp.sh > /tmp/watch-gp.log 2>&1 &
```

監控日誌：
```bash
tail -f /tmp/watch-gp.log
```

## 更新流程

1. 修改 `index.html`（添加新內容）
2. 自動監控腳本檢測變化
3. 自動推送至 GitHub main 分支
4. GitHub Pages 自動重建
5. 網站更新至 https://2324139.github.io/math-history/

## 緊急推送

若需立即部署（不等待監控）：
```bash
cd /home/node/.openclaw/workspace/math-history
bash deploy-gp.sh
```

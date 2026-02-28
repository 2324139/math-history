#!/bin/bash

# 設置 Cron 任務
# 用法：bash setup-cron.sh [install|remove|status]

ACTION="${1:-status}"
SCRIPT_PATH="/home/node/.openclaw/workspace/math-history/check-and-publish.sh"
CRON_JOB="0 * * * * bash $SCRIPT_PATH >> /tmp/cron-publish.log 2>&1"

case "$ACTION" in
  install)
    echo "📝 安裝 Cron 任務..."
    
    # 檢查腳本是否可執行
    chmod +x "$SCRIPT_PATH"
    
    # 添加到 crontab（避免重複）
    (crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH"; echo "$CRON_JOB") | crontab -
    
    echo "✅ Cron 任務已安裝"
    echo "   每小時檢查一次：0 * * * * （整點時刻）"
    crontab -l | grep check-and-publish
    ;;
  
  remove)
    echo "🗑️  移除 Cron 任務..."
    crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" | crontab -
    echo "✅ Cron 任務已移除"
    ;;
  
  status)
    echo "📊 Cron 任務狀態："
    if crontab -l 2>/dev/null | grep -q "check-and-publish"; then
      echo "✅ 已安裝"
      echo ""
      echo "排程："
      crontab -l | grep check-and-publish
      echo ""
      echo "最近日誌："
      tail -5 /tmp/cron-publish.log 2>/dev/null || echo "（暫無日誌）"
    else
      echo "❌ 未安裝"
    fi
    ;;
  
  test)
    echo "🧪 測試定時發佈腳本..."
    bash "$SCRIPT_PATH"
    echo "✅ 測試完成，詳見："
    echo "   /tmp/scheduled-deploy.log"
    echo "   /tmp/cron-publish.log"
    ;;
  
  *)
    echo "用法："
    echo "  bash setup-cron.sh install   - 安裝每小時定時檢查"
    echo "  bash setup-cron.sh remove    - 移除 Cron 任務"
    echo "  bash setup-cron.sh status    - 查看狀態"
    echo "  bash setup-cron.sh test      - 測試腳本"
    ;;
esac

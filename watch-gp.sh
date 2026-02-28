#!/bin/bash

# 持續監控 index.html，自動部署至 GitHub Pages

REPO_DIR="/home/node/.openclaw/workspace/math-history"
cd "$REPO_DIR"

LAST_HASH=$(md5sum index.html 2>/dev/null | awk '{print $1}')

echo "🔄 開始監控 index.html..."
echo "📍 部署目標：GitHub Pages (https://2324139.github.io/math-history/)"
echo ""

while true; do
    sleep 30
    
    CURRENT_HASH=$(md5sum index.html 2>/dev/null | awk '{print $1}')
    
    if [ "$CURRENT_HASH" != "$LAST_HASH" ] && [ ! -z "$CURRENT_HASH" ]; then
        echo ""
        echo "📝 [$(date '+%Y-%m-%d %H:%M:%S')] 檢測到變化，部署中..."
        bash deploy-gp.sh
        LAST_HASH=$CURRENT_HASH
        echo "✅ 部署完成"
    fi
done

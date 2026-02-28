#!/bin/bash

# 定時發佈文章檢查腳本
# 每小時檢查 scheduled-articles.json
# 若有文章達到發佈時間，自動添加到 index.html 並部署

REPO_DIR="/home/node/.openclaw/workspace/math-history"
SCHEDULED_FILE="$REPO_DIR/scheduled-articles.json"
INDEX_FILE="$REPO_DIR/index.html"
LOG_FILE="/tmp/scheduled-deploy.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 檢查待發佈文章..." >> $LOG_FILE

# 檢查 JSON 文件是否存在
if [ ! -f "$SCHEDULED_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ scheduled-articles.json 不存在" >> $LOG_FILE
    exit 0
fi

# 使用 Python 檢查並發佈
cd "$REPO_DIR" && python3 << 'PYEOF'
import json
import os
from datetime import datetime
import subprocess

SCHEDULED_FILE = "scheduled-articles.json"
INDEX_FILE = "index.html"
LOG_FILE = "/tmp/scheduled-deploy.log"

try:
    with open(SCHEDULED_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)
except:
    exit(0)

current_time = datetime.utcnow()
published_count = 0

# 檢查待發佈文章
for article in data.get('scheduled_articles', []):
    if article['status'] != 'scheduled':
        continue
    
    try:
        publish_time = datetime.strptime(article['publish_time'], '%Y-%m-%d %H:%M')
    except:
        continue
    
    # 檢查是否到達發佈時間
    if current_time >= publish_time:
        print(f"✅ 發佈文章：{article['title']}")
        
        # 從 index.html 讀取並插入文章
        with open(INDEX_FILE, 'r', encoding='utf-8') as f:
            html = f.read()
        
        # 構建文章卡片 HTML
        figures_html = ''.join([
            f'<span class="tag tag-figure" onclick="filterFigure(\'{fig}\')">{fig}</span>'
            for fig in article['figures']
        ])
        
        article_card = f"""
    <div class="article-card visible">
        <h4>📚 {article['title']}</h4>
        <p class="article-meta"><strong>分類：</strong> {article['category']}</p>
        <div class="article-tags">
            {figures_html}
        </div>
    </div>
"""
        
        # 插入到 articlesContainer 的開始
        insert_marker = '<div id="articlesContainer" class="articles-grid">'
        if insert_marker in html:
            html = html.replace(insert_marker, insert_marker + article_card)
            
            # 寫回 HTML
            with open(INDEX_FILE, 'w', encoding='utf-8') as f:
                f.write(html)
            
            # 更新 JSON 狀態
            article['status'] = 'published'
            article['published_time'] = current_time.strftime('%Y-%m-%d %H:%M:%S')
            data['published_articles'].append(article)
            data['scheduled_articles'].remove(article)
            
            with open(SCHEDULED_FILE, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            
            published_count += 1
            
            # 記錄日誌
            with open(LOG_FILE, 'a', encoding='utf-8') as log:
                log.write(f"[{current_time.strftime('%Y-%m-%d %H:%M:%S')}] ✅ 已發佈：{article['title']}\n")

# 若有新文章發佈，執行 git commit 與推送
if published_count > 0:
    os.system('cd /home/node/.openclaw/workspace/math-history && git add index.html scheduled-articles.json')
    os.system('git commit -m "自動發佈 {} 篇文章 ({})".format(published_count, current_time.strftime("%Y-%m-%d %H:%M"))')
    os.system('git push origin main')
    
    with open(LOG_FILE, 'a', encoding='utf-8') as log:
        log.write(f"[{current_time.strftime('%Y-%m-%d %H:%M:%S')}] 🚀 已推送至 GitHub\n")

PYEOF

exit 0

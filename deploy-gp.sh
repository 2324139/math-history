#!/bin/bash

# GitHub Pages 自動部署腳本
# 每當 index.html 變化時自動部署

REPO_DIR="/home/node/.openclaw/workspace/math-history"
DEPLOY_DIR="/tmp/gh-pages-deploy-auto"
# 令牌應從環境變數讀取，或使用 SSH key
GITHUB_URL="https://github.com/2324139/math-history.git"
GITHUB_PAGES_URL="https://2324139.github.io/math-history/"

cd "$REPO_DIR"

echo "📤 部署至 GitHub Pages..."

# 清理與準備
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"
cp index.html "$DEPLOY_DIR/"

# 初始化部署倉庫
cd "$DEPLOY_DIR"
git init
git config user.name "Zero"
git config user.email "zero@math-history.local"

# 添加並提交
git add index.html
git commit -m "自動部署：$(date '+%Y-%m-%d %H:%M:%S')" || true

# 推送至 main 分支（GitHub Pages 源）
git push -f "$GITHUB_URL" HEAD:main

echo "✅ 部署完成！"
echo "🌐 網址：$GITHUB_PAGES_URL"

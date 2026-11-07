#!/usr/bin/env bash
# 合并站点构建：修仙（本仓库 docs/）+ 人生重开模拟器（预构建产物在 site/remake/）+ 游戏大厅首页
set -euo pipefail

echo "node: $(node -v)"
echo "pnpm: $(pnpm -v || echo none)"

# 1) 构建修仙，产物在 docs/
pnpm install --no-frozen-lockfile || true
pnpm build

# 2) 组装
rm -rf site-out
mkdir -p site-out/xiuxian site-out/remake
cp -R docs/. site-out/xiuxian/
cp -R site/remake/. site-out/remake/
cp site/index.html site-out/index.html
rm -f site-out/remake/.nojekyll

# 3) 自检
test -f site-out/index.html || { echo "!! missing launcher"; exit 1; }
test -f site-out/xiuxian/index.html || { echo "!! missing xiuxian build"; exit 1; }
test -f site-out/remake/index.html || { echo "!! missing remake build"; exit 1; }
echo "==> site assembled"
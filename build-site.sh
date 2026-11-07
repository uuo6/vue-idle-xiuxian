#!/usr/bin/env bash
# 合并构建：修仙（本仓库）+ 人生重开模拟器（VickScarlet/remake）+ 选游戏首页
set -euo pipefail

echo "node: $(node -v)"
echo "pnpm: $(pnpm -v || echo none)"

# remake 的 @remake/data 包依赖 bunx
if ! command -v bunx >/dev/null 2>&1; then
  echo "==> installing bun"
  curl -fsSL https://bun.sh/install | bash || true
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi
echo "bun: $(bun -v 2>/dev/null || echo missing)"

REPO_ROOT="$PWD"
echo "==> repo root: $REPO_ROOT"

# 1) 构建修仙（输出到 docs/）
pnpm install --no-frozen-lockfile || true
pnpm build

# 2) 构建人生重开模拟器
rm -rf /tmp/remake
git clone --depth 1 https://github.com/VickScarlet/remake /tmp/remake
cd /tmp/remake
pnpm install --no-frozen-lockfile || true
pnpm --filter @remake/data build
pnpm --filter @remake/web build
cd "$REPO_ROOT"

# 3) 组装站点
rm -rf site-out
mkdir -p site-out/xiuxian site-out/remake
cp -R docs/. site-out/xiuxian/
cp -R /tmp/remake/apps/web/dist/. site-out/remake/
cp site/index.html site-out/index.html
rm -f site-out/remake/.nojekyll

echo "==> site assembled"
find site-out -maxdepth 2 -type d

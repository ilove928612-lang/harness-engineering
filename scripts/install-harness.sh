#!/usr/bin/env bash
# install-harness.sh — 把 harness-engineering 的 curate-research skill 分发到 5 个 agent 端
#
# 5 端: Claude Code / Codex / Grok / Claw (OpenClaw·ClawX) / Hermes
# 用法:
#   bash scripts/install-harness.sh          # dry-run: 打印将安装到哪些位置
#   bash scripts/install-harness.sh --apply  # 实际复制（不覆盖已存在的目标）
#
# 设计约束:
#   - 不覆盖任何已存在的 skill（-n 语义）——已装过的端静默跳过
#   - 只分发 skill；check-consistency.sh / hooks / AGENTS.md 是仓库内资产，
#     各端 agent 在仓库目录内工作时自然可见，无需复制
#   - Windows git-bash 下 ~ 解析为 C:\Users\<user>

set -u
SRC="$(cd "$(dirname "$0")/.." && pwd)/.claude/skills/curate-research"
APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

if [ ! -d "$SRC" ]; then
  echo "✗ 源 skill 不存在: $SRC"
  exit 1
fi

# 端名 | 目标目录 | 说明
TARGETS=(
  "Claude Code|$HOME/.claude/skills|用户级 skills"
  "Codex|$HOME/.codex/skills|用户级 skills"
  "Grok|$HOME/.grok/skills|用户级 skills"
  "Claw/OpenClaw|$HOME/.openclaw/skills|用户级 skills"
  "Hermes|${HERMES_HOME:-$HOME/.hermes}/skills|HERMES_HOME 或默认"
)

echo "=== curate-research skill → 5 端分发 ($([ $APPLY -eq 1 ] && echo APPLY || echo DRY-RUN)) ==="
echo "源: $SRC"
echo

for entry in "${TARGETS[@]}"; do
  name="${entry%%|*}"; rest="${entry#*|}"
  dir="${rest%%|*}"; note="${rest#*|}"
  if [ ! -d "$dir" ]; then
    echo "[$name] ✗ 目录不存在，跳过: $dir ($note)"
    continue
  fi
  if [ -e "$dir/curate-research" ]; then
    echo "[$name] ✓ 已安装，跳过（不覆盖）: $dir/curate-research"
    continue
  fi
  if [ $APPLY -eq 1 ]; then
    cp -r "$SRC" "$dir/curate-research" && \
      echo "[$name] ✓ 已安装: $dir/curate-research" || \
      echo "[$name] ✗ 复制失败"
  else
    echo "[$name] → 将安装: $dir/curate-research  ($note)"
  fi
done

echo
if [ $APPLY -eq 1 ]; then
  echo "完成。验证: 各端执行 'skills' 相关命令查看 curate-research 是否被识别。"
else
  echo "dry-run 完成。确认无误后执行: bash scripts/install-harness.sh --apply"
fi

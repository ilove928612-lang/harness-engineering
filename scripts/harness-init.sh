#!/usr/bin/env bash
# harness-init.sh — 在任意项目里初始化 Harness Engineering 脚手架
# 用法:
#   bash scripts/harness-init.sh <目标项目目录> [项目名]
# 生成: AGENTS.md / scripts/check-harness.sh / .claude/skills/harness-workflow/SKILL.md
# 已存在的文件跳过（不覆盖）。
set -u
SCAFFOLD="$(cd "$(dirname "$0")/../scaffold" && pwd)"
TARGET="${1:?用法: harness-init.sh <目标目录> [项目名]}"
NAME="${2:-$(basename "$TARGET")}"

[ -d "$TARGET" ] || { echo "✗ 目标目录不存在: $TARGET"; exit 1; }

# AGENTS.md — 占位符替换
if [ ! -e "$TARGET/AGENTS.md" ]; then
  sed -e "s/{{PROJECT_NAME}}/$NAME/g" \
      -e '/{{STRUCTURE_ROWS}}/d' \
      -e '/{{ENTRY_DOCS}}/d' \
      "$SCAFFOLD/AGENTS.md.tpl" > "$TARGET/AGENTS.md"
  echo "✓ AGENTS.md"
else
  echo "– AGENTS.md 已存在，跳过"
fi

# check-harness.sh
if [ ! -e "$TARGET/scripts/check-harness.sh" ]; then
  mkdir -p "$TARGET/scripts"
  cp "$SCAFFOLD/check-harness.sh" "$TARGET/scripts/check-harness.sh"
  echo "✓ scripts/check-harness.sh"
else
  echo "– scripts/check-harness.sh 已存在，跳过"
fi

# harness-workflow skill（.claude 目录是 5 端通用约定：Claude/Codex/Grok/Claw/Hermes 均读）
if [ ! -e "$TARGET/.claude/skills/harness-workflow/SKILL.md" ]; then
  mkdir -p "$TARGET/.claude/skills/harness-workflow"
  cp "$SCAFFOLD/harness-workflow/SKILL.md" "$TARGET/.claude/skills/harness-workflow/SKILL.md"
  echo "✓ .claude/skills/harness-workflow/SKILL.md"
else
  echo "– harness-workflow skill 已存在，跳过"
fi

echo
echo "完成。进入 $TARGET 后:"
echo "  1. 编辑 AGENTS.md 填仓库结构表与入口文档"
echo "  2. bash scripts/check-harness.sh  # 首次校验应全绿"
echo "  3. 对 agent 说「按项目规矩来」即可触发 harness-workflow"

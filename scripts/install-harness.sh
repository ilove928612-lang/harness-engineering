#!/usr/bin/env bash
# install-harness.sh — 把 harness-engineering 的 skill 分发到 5 个 agent 端
#
# 分发: curate-research（仓库自策展）+ harness-workflow（六大概念编码循环）
#       + workflow-loop（三方闭环自动路由）
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
REPO="$(cd "$(dirname "$0")/.." && pwd)"
APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

SKILLS=("curate-research" "harness-workflow" "workflow-loop")

# 端名 | 目标目录 | 说明
TARGETS=(
  "Claude Code|$HOME/.claude/skills|用户级 skills"
  "Codex|$HOME/.codex/skills|用户级 skills"
  "Grok|$HOME/.grok/skills|用户级 skills"
  "Claw/OpenClaw|$HOME/.openclaw/skills|用户级 skills"
  "Hermes|${HERMES_HOME:-$HOME/.hermes}/skills|HERMES_HOME 或默认"
)

echo "=== harness skill → 5 端分发 ($([ $APPLY -eq 1 ] && echo APPLY || echo DRY-RUN)) ==="
for skill in "${SKILLS[@]}"; do
  src="$REPO/.claude/skills/$skill"
  [ -d "$src" ] || src="$REPO/scaffold/$skill"
  if [ "$skill" = "workflow-loop" ]; then
    # 源是 practice 实验目录：只复制 SKILL.md（README/AGENTS 是仓库文档，不进 skill 目录）
    src="$REPO/practice/02-workflow-loop-routing/SKILL.md"
  else
    [ -d "$src" ] || { echo "✗ 源 skill 不存在: $skill"; continue; }
  fi
  [ -e "$src" ] || { echo "✗ 源 skill 不存在: $skill"; continue; }
  echo "--- $skill (源: $src) ---"
  for entry in "${TARGETS[@]}"; do
    name="${entry%%|*}"; rest="${entry#*|}"
    dir="${rest%%|*}"; note="${rest#*|}"
    if [ ! -d "$dir" ]; then
      echo "  [$name] ✗ 目录不存在，跳过: $dir ($note)"
      continue
    fi
    if [ -e "$dir/$skill" ]; then
      echo "  [$name] ✓ 已安装，跳过（不覆盖）"
      continue
    fi
    if [ $APPLY -eq 1 ]; then
      if [ -f "$src" ]; then
        mkdir -p "$dir/$skill" && cp "$src" "$dir/$skill/SKILL.md"           && echo "  [$name] ✓ 已安装: $dir/$skill/SKILL.md" || echo "  [$name] ✗ 复制失败"
      else
        cp -r "$src" "$dir/$skill" && echo "  [$name] ✓ 已安装: $dir/$skill" || echo "  [$name] ✗ 复制失败"
      fi
    else
      echo "  [$name] → 将安装: $dir/$skill  ($note)"
    fi
  done
done

echo
if [ $APPLY -eq 1 ]; then
  echo "完成。验证: 各端执行 'skills' 相关命令查看 skill 是否被识别。"
else
  echo "dry-run 完成。确认无误后执行: bash scripts/install-harness.sh --apply"
fi

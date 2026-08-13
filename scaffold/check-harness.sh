#!/usr/bin/env bash
# check-harness.sh — 机械化执行：文档会腐烂，lint 规则不会
# 由 harness-init 生成。守护 3 条不变量：
#   C1 AGENTS.md 里引用的相对路径全部真实存在（死链接 = FAIL）
#   C2 所有 markdown 表格列数与表头一致
#   C3 无裸 TODO/FIXME 残留（要么做掉，要么写明 issue 编号）
# 用法: bash scripts/check-harness.sh
set -u
FAIL=0
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# C1: AGENTS.md 内 [x](path) 相对链接存在性
while IFS= read -r p; do
  case "$p" in
    http*|mailto:*|'#'*) continue ;;
  esac
  [ -e "$ROOT/$p" ] || { echo "C1 FAIL: AGENTS.md 死链接 → $p"; FAIL=1; }
done < <(grep -oE '\]\([^)#]+\)' "$ROOT/AGENTS.md" | sed 's/^](//;s/)$//')

# C2: 表格列数一致性。判定标准：表头行后紧跟分隔行(|--|)，分隔行后所有 | 行与表头比列数
while IFS= read -r f; do
  awk -F'|' '
    function is_sep() { return $0 ~ /^[[:space:]]*\|[[:space:]-]+\|([[:space:]-]+\|)*[[:space:]]*$/ }
    /^\|/ && !is_sep() {
      if (pending) { h=n=NF-2; in_tbl=0 }
      else if (in_tbl && NF-2 != h) { print FILENAME": 列数 "(NF-2)" != 表头 "h" → 第 "NR" 行"; bad=1 }
      else if (!in_tbl) { pending=1; ph=NF-2 }
      next
    }
    is_sep() { if (pending) { h=ph; pending=0; in_tbl=1 } next }
    { pending=0; in_tbl=0 }
    END { exit bad?1:0 }
  ' "$f" && echo "C2 PASS: $f" || { echo "C2 FAIL: $f"; FAIL=1; }
done < <(find "$ROOT" -name '*.md' -not -path '*/node_modules/*' -not -path '*/.git/*')

# C3: 裸 TODO/FIXME（无 issue 编号；只扫代码文件，文档中提及不算）
if grep -rEn 'TODO|FIXME' "$ROOT" --include='*.py' --include='*.ts' --include='*.js' --include='*.rs' 2>/dev/null \
   | grep -vE '#[0-9]+' | grep -v '\.git/'; then
  echo "C3 FAIL: 发现裸 TODO/FIXME（写明 issue 编号或做掉）"
  FAIL=1
else
  echo "C3 PASS: 无裸 TODO/FIXME"
fi

[ $FAIL -eq 0 ] && echo "✓ all harness checks passed" || { echo "✗ fix the entries above and re-run"; exit 1; }

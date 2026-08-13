---
name: workflow-loop
description: 自动闭环路由 —— 任何"实现/开发/修复/做功能/跑完再叫我"请求，按规模自动分流到 superpowers 链或 vloop 三层闭环，无需用户输入命令。小任务（≤2 文件/单 story）→ superpowers 链（brainstorming → writing-plans → tdd → requesting-code-review）；大任务（3+ 独立 stories / PRD / spec / 无人值守意图）→ vloop 协议（L1 execute → L2 judge → L3 human）。ponytail 懒人模式全程在线（hook 自动，无需触发）。当用户下达开发类任务时自动启用。
---

# workflow-loop —— 三方自动闭环路由

> 职责边界：superpowers 管"怎么干活"（流程方法论），vloop 管"闭环验收"（三层门控），ponytail 管"少写代码"（懒人 hook）。本 skill 是唯一的路由决策点，防止三者同时抢任务。

## 自动分流（无需用户命令，按规模判定）

### 判定规则

| 信号 | 路由 |
|------|------|
| 单文件修复 / 小功能（≤2 文件） | **superpowers 链**：brainstorming → writing-plans → test-driven-development → requesting-code-review |
| 3+ 独立 stories / PRD / spec / issue 清单 | **vloop 协议**：读 vloop skill references/loop-protocol.md，按 L1→L2→L3 执行 |
| 无人值守意图（"跑完再叫我 / overnight / 不用逐步确认"） | **vloop 协议**（L3 人类闸门仍保留，merge/deploy 永远等人） |
| 查询 / 解释 / 探索 / 单行改动 | 不触发闭环，直接回答 |

### 执行约束（防打架）

1. **每次任务只走一条链**——按上表路由后，另一条链的 skill 不加载、不触发
2. **vloop 大任务优先**：若判定走 vloop，superpowers 的 brainstorming/writing-plans 让位——vloop 自带 planner 角色写 plan.md，不需要 superpowers 的计划
3. **ponytail 全程叠加**：它是 pre_llm_call hook 自动生效，不参与路由、不需要触发、不与其他链冲突
4. **不主动向用户推销 vloop**：用户已授权自动路由（本 skill 即授权），不再弹"要不要跑 vloop"确认卡——除非任务触及 L3 硬闸门（merge/deploy/publish/delete/charge）
5. **vloop 免命令执行**：跳过 `/vloop setup` 交互式问答——按 references/configurator.md 用合理默认值生成 loop.json + prd.json，默认单 agent tiered 形态；用户明确要给参数时再问

## 闭环状态机（vloop 大任务）

```
plan → execute(单任务/次) → judge(异构只读) → passes? → 下一任务
                                          └→ ≤3 轮 redesign → 仍败 → L3 人类
全部通过 → L3 人类审批 → merge/deploy 必须人批
```

## 相关

- superpowers 链：skills/brainstorming、writing-plans、test-driven-development、requesting-code-review
- vloop 协议：plugins/vloop/skills/vloop/（references/loop-protocol.md）
- 本 skill 与三者关系：路由层，不重复实现任何一方的逻辑

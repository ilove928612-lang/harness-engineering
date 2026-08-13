# 三方闭环自动路由：superpowers × vloop × ponytail 共存设计

> 日期：2026-08-14
> 场景：同一台机器上三个 agent 方法论插件并存，如何避免互相抢任务、零命令输入自动触发

---

## 问题

装了三套方法论 skill，全都会在“开始干活”时被触发：

- **superpowers**（obra, 271k★）— 流程方法论：brainstorming → writing-plans → TDD → code-review
- **vloop**（wikieden）— 三层闭环：L1 execute → L2 judge（异构只读）→ L3 human，带验收门控
- **ponytail**（Dietrich Gebert）— 懒人模式：pre_llm_call hook，always-on

冲突点：vloop 的 proactive trigger 和 superpowers 的 brainstorming 会同时响应“实现 X”；如果再加命令式 `/vloop setup`，用户被迫记命令。

## 解法：一个路由 skill 分流，零命令

**workflow-loop**（SKILL.md，~50 行）—— 唯一的路由决策点：

| 信号 | 路由 |
|------|------|
| ≤2 文件 / 单 story | superpowers 链（brainstorm → plan → TDD → review） |
| 3+ stories / PRD / 无人值守意图 | vloop 协议（L1→L2→L3） |
| 查询 / 探索 / 单行改动 | 不触发，直接答 |
| 全程 | ponytail hook 自动叠加 |

**防打架五规则**：
1. 每任务只走一条链，路由后另一链 skill 不加载
2. vloop 优先：走 vloop 时 superpowers 的 plan 让位（vloop 自带 planner）
3. ponytail 是 hook 不参与路由，永远在线
4. 取消 vloop 确认卡（用户已授权自动路由）——但 L3 硬闸门（merge/deploy/delete）永远等人
5. vloop 免命令执行：跳过 `/vloop setup` 交互问答，合理默认值生成 loop.json + prd.json

## 设计要点

- **触发全自动**：Hermes skill 机制按 description 匹配（“实现/修复/跑完再叫我”），ponytail 是 hook，全程零输入
- **保留的唯一人工点**：L3 闸门（merge/deploy/delete 前等确认）——安全底线不可自动
- **路由层不重复实现**：workflow-loop 只做分流，不复制任何一方的逻辑
- **每任务单链**：避免多 skill 同时激活导致模型选择困难（Hermes 会话里同时加载 3 套流程 skill 会让 agent 不知道听谁的）

## 产物

- `workflow-loop/SKILL.md` — 路由 skill（Hermes skills 目录，5 端可复用同构安装）
- 三方各司其职：superpowers 管“怎么干活”，vloop 管“闭环验收”，ponytail 管“少写代码”

## 下一步

- 5 端同构安装 workflow-loop（install-harness.sh 加第三项）
- 实测大任务自动走 vloop、小任务自动走 superpowers，验证路由不打架

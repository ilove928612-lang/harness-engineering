# Ralph Orchestrator

> 首篇实测工具页。实测来源：[practice/01-ralph-demo/](../../practice/01-ralph-demo/)（v2.8.1，2026-03-31）。

## 一句话定位

把"让智能体循环工作直到完成"从 bash 脚本（原版 [snarktank/ralph](https://github.com/snarktank/ralph)）升级为 Rust 编排器：帽子（Hat）角色系统 + 事件驱动协调 + 背压门控 + 持久化 scratchpad，后端可插拔（Claude / Kiro / Gemini / Codex）。

## 降低哪些维度的复杂度

对照 [6 维复杂度框架](../../thinking/software-project-complexity-in-the-ai-era.md)，按实测判断：

| 维度 | 是否降低 | 依据（实测） |
|------|---------|-------------|
| 验证成本（主战场） | ✅ 显著 | 背压门控：Builder 必须测试全绿才能交棒；Critic 独立重跑 pytest + 手动验证 5 种 CLI 路径，不靠自我评估 |
| 探索收敛 | ✅ | 帽子系统把每轮迭代约束在单一角色职责内（Planner/Builder/Critic/Finalizer），不发散 |
| 暗知识 | ✅ 轻度 | scratchpad.md 把跨迭代决策显式化落盘——"磁盘是状态，Git 是记忆" |
| 上下文压力 | ◐ 间接 | Fresh Context 信条：每轮清空重读，避免长会话腐化；但这转移而非消除了上下文成本 |
| 可提示性 / 状态纠缠 | ✗ 不解决 | 任务本身好不好描述、代码耦合度高不高，Ralph 无能为力 |
| **胶囊化能力（分母）** | ✅ | 它就是"坐在循环上，不坐在循环里"的胶囊——人类输入收敛为一份 PROMPT.md |

## 实测体验

- **生效场景**：需求明确、可测试的小任务。实测 4 轮迭代 / 321 秒 / $0.31 完成 CLI word counter，含 TDD、自愈（Builder 自己发现并修掉 char count bug）、独立评审、显式完成信号（`LOOP_COMPLETE`）。
- **生效边界**：整个门控体系建立在"测试能表达正确性"之上。如 [thinking/evaluation-elephant-in-the-room.md](../../thinking/evaluation-elephant-in-the-room.md) 所指出的——Critic Hat 是折中，**它仍然是 LLM**；需求理解本身错了，测试全绿也救不了。
- **失效场景**：
  1. 需求模糊 / 正确性难以形式化的任务（设计、产品决策）——背压门控没有可靠的"坏结果"判据；
  2. `completion_promise` 是字符串匹配，模型过早输出 `LOOP_COMPLETE` 即可终止循环，Finalizer 的整提示词门是缓解不是根除；
  3. 成本随任务规模的扩展性未实测（toy task 之外无数据）。

## 搭配建议

- 与 [practice/01-ralph-demo/](../../practice/01-ralph-demo/) 的归档配置（`ralph.yml` + `PROMPT.md`）配合即可复跑。
- 后端用 Claude Code（本次实测组合）；PROMPT.md 中显式写完成信号与测试要求，等于把背压条件交给人类掌控。

## 替代方案

| 项目 | 与 Ralph Orchestrator 的差异 |
|------|------------------------------|
| [snarktank/ralph](https://github.com/snarktank/ralph)（原版） | bash 脚本，六条信条的最小实现；无帽子角色、无事件协调，适合理解思想本源 |
| [bmad-ralph](https://github.com/qianxiaofeng/bmad-ralph) | BMAD 方法论 + 并行 Claude Code worktree + 三层自愈 + SQLite 状态机，面向更重的多任务并行 |

Ralph 六条信条与 Harness Engineering 概念的完整映射见根 [README.md](../../README.md) "Ralph 系列"一节。

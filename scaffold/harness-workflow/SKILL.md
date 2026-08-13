---
name: harness-workflow
description: 在任意项目里按 Harness Engineering 六大概念驱动 agent 写代码：先读 AGENTS.md 地图 → 小步实现 → 跑 check-harness.sh 机械化校验 → 提交。当用户说"开始干活 / 实现这个功能 / 按项目规矩来 / 先看 AGENTS.md"时使用。适用于任何已初始化 harness 的项目（有 scripts/check-harness.sh 即视为已初始化）。
---

# harness-workflow —— 六大概念驱动的编码循环

> 一套可复制的 Harness Engineering 工作循环，物化六大概念为可执行步骤。
> 由 harness-init 生成，5 端（Claude Code / Codex / Grok / Claw / Hermes）通用。

## 何时用

- 用户让 agent 在项目里实现 / 修改 / 修复功能
- 项目有 `scripts/check-harness.sh`（已初始化 harness 的标志）
- 用户说"按项目规矩来" / "先看 AGENTS.md"

## 循环（每任务必走 4 步）

### 1. 读地图（地图而非手册）
先读 `AGENTS.md`，再按它的链接渐进式读相关文档。**不要**一次读完整个仓库。
AGENTS.md 是目录页，指向更深层；巨型指令文件是坏味道。

### 2. 小步实现（吞吐量改变合并理念）
一个逻辑变更一个 commit。纠错成本低、等待成本高——测试偶发失败直接重跑，
不要卡住等人工。实现前 grep 仓库已有模式：智能体会复现已有模式，包括坏模式。

### 3. 机械化校验（文档会腐烂，lint 不会）
每次提交前跑 `bash scripts/check-harness.sh`，C1–C3 必须全绿：
- C1 AGENTS.md 相对链接真实存在（死链接 = FAIL）
- C2 所有 markdown 表格列数与表头一致
- C3 无裸 TODO/FIXME（写明 issue 编号可豁免）
校验失败 = 修复后再提交，绝不带红提交。

### 4. 提交（仓库即记录系统）
- 提交信息写明动机，一个变更一个 commit
- 决策、规范、计划写成文件进仓库——不在仓库里的东西对智能体不存在
- 不 push，除非用户要求

## 硬性规则（不可商量）

- 不引入未声明的依赖；优先"无聊"技术（API 稳定、训练集覆盖好）
- 所有路径引用必须真实存在
- 破坏性操作（删文件 / 改共享配置 / 迁移）先和用户确认

## 相关

- 生成器：`harness-init`（见 harness-engineering 仓库 `scaffold/`）
- 校验脚本：`scripts/check-harness.sh`
- 六大概念详解：concepts/00-overview.md（harness-engineering 仓库）

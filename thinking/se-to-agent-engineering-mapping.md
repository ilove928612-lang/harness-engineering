# 传统软件工程 ↔ AI Agent 工程：一张对照表，与它的三处修正

> 起点：本人 2026-07-22 随手总结的一张 15 行对照表（下文原样保留）。
> 本文把这张表当作可检验的论题，用 [references/articles.md](../references/articles.md) 的文献逐行校验，
> 得到：一个框架级修正（主语混了三层）、三行补全、两处语义走样、一个时间戳限定。
> 日期：2026-07-22

---

## 原表（2026-07-22 快照，未修订）

| 传统软件工程 | AI Agent / LLM 工程 |
|---|---|
| 利益相关者沟通、需求澄清 | 用户意图、System Prompt、任务 Context、Human in the Loop |
| 用户故事、功能与非功能需求 | 任务目标、行为边界、输出 Schema、Q/T/C 约束 |
| 架构原则、模块划分、关注点分离 | 数据流 / 控制流 / 反馈流分离；Prompt、Context、Plan、Tool、Hook 分层 |
| 数据管理、持久化、数据架构 | 检索 / RAG、短期 / 长期记忆、知识库、缓存与失效、上下文组装 |
| 编码规范、团队约定 | AGENTS.md、CLAUDE.md、System Prompt、Skill、模板 |
| 版本管理、配置管理、依赖锁定 | Prompt / Context / Skill 版本化、模型版本钉选、Tool / 依赖锁定、可回滚基线 |
| 技术方案、任务分解、设计评审 | Plan-before-Act、步骤依赖、fallback、abort conditions |
| 编写与修改代码 | diff / patch 增量编辑、原子化 Tool 调用、改动幅度控制、可追溯的编辑意图 |
| 最小权限、变更控制、安全审查 | Tool 白名单、副作用分级、Pre-Hook、人工审批 |
| 验收条件、Definition of Done | success_criteria、质量阈值、停止条件 |
| 单元测试、集成测试、静态分析、CI 门禁 | Post-Hook、测试套件、Linter、Schema 校验、Golden Set |
| Code Review、QA、验收评审 | 语义评估、LLM-as-judge、Human on the Loop、升级机制 |
| 部署、发布、灰度、回滚 | Prompt / 模型变更上线、canary / A-B、影子流量、一键回滚 |
| 日志、监控、Tracing、SRE | 结构化日志、Metrics、Trace、在线评估、分布漂移检测 |
| 复盘、根因分析、持续改进 | 归因、消融实验、Trace Replay、Skill 更新 |

隐含论题：**AI Agent 工程是传统软件工程各活动的同构映射**——每个传统活动都有一个 agent 时代的对应物。这个论题大方向成立（下文有逐行文献背书），但"同构"二字需要三处修正。

---

## 修正一（框架级）：右列的主语混了三层

左列主语统一是"人"；右列其实是三张表的叠加。按 #55 的内环/外环语言与 Fowler《Humans and Agents》的 in/on the loop 划分：

- **① 人对 agent 做的事**（外环输入与约束设计）——意图、Schema、AGENTS.md、白名单、success_criteria
- **② agent 自己做的事**（内环执行）——Plan-before-Act、diff/patch 编辑、环内传感器自纠
- **③ 人对"人-agent 系统"做的事**（外环问责与运维）——灰度、观测、归因、Skill 更新

最能暴露混层的是"编写与修改代码 → diff/patch 增量编辑"这一行：左边是人写代码，右边是 agent 怎么编辑代码——**主语已经换了**，但一行对一行的形式让它看起来像"同一件事的新做法"。这张表真正记录的不是活动的翻译，而是 #1、#55、#56 说的那件事：**人的工作对象整体上移一层，从做这些活动，变成设计让智能体做这些活动的系统。**

原表有一处对这个分层的直觉已经很准：需求侧用 Human **in** the Loop，验收侧用 Human **on** the Loop——in/on 分置正是 ① 与 ③ 的边界。

---

## 修正二：补全三行

原表缺了三个在文库里反复出现的主题，其中两个恰好是"范式转移最大"的地方：

| 传统软件工程 | AI Agent / LLM 工程 | 环位 | 依据 |
|---|---|---|---|
| 重构、技术债偿还 | 熵管理 = 垃圾回收：后台 agent 扫描偏差、更新质量评分、发起重构 PR；**harness 自身瘦身**（"what can I stop doing"） | ③ | #1 概念 6、#6、[cross-article-insights](cross-article-insights.md) 洞见 1 的 Harness Gardening |
| 分支策略、团队并行协作、合并流程 | 多 agent 编排（planner/worker/judge）、worktree 隔离、任务锁、乐观并发；**吞吐量改变合并理念**（纠错成本低于等待成本） | ①③ | #1 概念 5、#48、#49、#56 |
| 项目跨月持续（左列的隐含时间维度） | session 即事件日志、snapshot/断点续跑、progress file、跨会话交接、init.sh 环境重建 | ① | #7 brain/hands/session、Osmani 三堵墙（观察项）、OpenAI Agents SDK（观察项） |

第三行值得单独说：原表右列的词汇几乎全部来自**单次会话内的机制**（Pre/Post-Hook、Tool 调用、上下文组装），而 2026 年上半年官方件的最大公共主题恰恰是跨会话持久层——"模型记住的是 transcript，harness 必须记住 truth"。左列的"项目活好几个月"是隐含前提，右列必须把它显式化。

---

## 修正三：两处语义走样

**版本钉选的风险方向是反的。** 传统依赖锁定的失败模式是"不升级 → 安全漏洞"；模型版本钉选的失败模式是"钉住模型 = 钉住 harness 对旧模型缺陷的补偿假设"，模型升级时这些补偿变成死重——#6 的 context resets 被 Opus 4.5 一代淘汰是标准案例，[cross-article-insights](cross-article-insights.md) 洞见 3 的循环依赖是机制解释。映射成立，但左右两边的失败模式**互为镜像**：一边怕锁太久，一边怕解锁那天。

**评估被平铺成了"活动之二"。** 原表把测试映射到 Post-Hook/Golden Set、把 review 映射到 LLM-as-judge，格式上与其他行等权。但评测三部曲（#34/#35/#38）+ #47 + #56 的共同结论是：评估在 agent 时代发生了**地位跃迁**——它不是流水线的一站，而是自主权上限的定价资产。Bun 案例里那套语言无关的百万断言测试套件是整个方法论的抵押物（[fix-the-process-not-the-code](fix-the-process-not-the-code.md)）；[evaluation-elephant-in-the-room](evaluation-elephant-in-the-room.md) 论证过行为正确性验证是整个体系的阿喀琉斯之踵。一行对一行的格式天然表达不出"这一行决定其他所有行能授予多少自主权"。

---

## 修订版全表（18 行，带环位与依据）

| # | 传统软件工程 | AI Agent / LLM 工程 | 环位 | 关键依据 |
|---|---|---|---|---|
| 1 | 利益相关者沟通、需求澄清 | 用户意图、System Prompt、任务 Context、Human in the Loop | ① | #20 SPDD、#16 SPEC.md |
| 2 | 用户故事、功能与非功能需求 | 任务目标、行为边界、输出 Schema、Q/T/C 约束 | ① | #25 越界测量、#43 用量治理 |
| 3 | 架构原则、模块划分、关注点分离 | 数据流/控制流/反馈流分离；Prompt、Context、Plan、Tool、Hook 分层 | ① | 原创格；完备性可用 #57 九维（D1–D9）校验，缺"执行环境"与"训练桥" |
| 4 | 数据管理、持久化、数据架构 | 检索/RAG、短期/长期记忆、知识库、缓存与失效、上下文组装 | ①② | #22 interpreter、#39 prompt caching |
| 5 | 编码规范、团队约定 | AGENTS.md、CLAUDE.md、Skill、模板 | ① | #1 概念 2、#8 |
| 6 | 版本管理、配置管理、依赖锁定 | Prompt/Skill 版本化、模型钉选 ⚠、可回滚基线 | ①③ | #23；⚠ 风险方向与传统相反（见修正三） |
| 7 | 技术方案、任务分解、设计评审 | Plan-before-Act 🕐、步骤依赖、fallback、abort conditions | ② | #4；🕐 最可能滑动的一格（见"时间戳"） |
| 8 | 编写与修改代码 | diff/patch 增量编辑、原子化 Tool 调用、可追溯编辑意图 | ② | #17/#30 工具原语、#13 |
| 9 | 最小权限、变更控制、安全审查 | Tool 白名单（= 能力授予）、副作用分级、Pre-Hook、人工审批 | ① | #50、#33、claude-code-harness R01–R13 |
| 10 | 验收条件、Definition of Done | success_criteria、质量阈值、停止条件、sprint contract | ① | #4 合同协商、#43 `/goal` 独立判停 |
| 11 | 单元测试、集成测试、静态分析、CI 门禁 | Post-Hook、测试套件、Linter、Schema 校验、Golden Set ⚠ | ②（人设计、环内自动跑） | #2 计算性传感器、#19；⚠ 地位跃迁（见修正三） |
| 12 | Code Review、QA、验收评审 | 对抗评审（激励结构分离）、LLM-as-judge、Human on the Loop、升级机制 | ③ | #56 实现者/评审者分离、#19 |
| 13 | 部署、发布、灰度、回滚 | Prompt/模型变更上线、canary/A-B、影子流量、一键回滚 | ③ | #23 第一手反例 |
| 14 | 日志、监控、Tracing、SRE | 结构化日志、Metrics、Trace、在线评估、漂移检测 | ③ | #24 三支柱、#27 |
| 15 | 复盘、根因分析、持续改进 | 归因、消融实验、Trace Replay、Skill 更新 | ③ | #9 飞轮、#15、#36 沉淀为 Skill |
| 16 | 重构、技术债偿还 | 熵管理 = 垃圾回收、harness 自身瘦身 | ③ | #1 概念 6、#6 |
| 17 | 分支策略、团队并行协作 | 多 agent 编排、worktree 隔离、吞吐量改变合并理念 | ①③ | #1 概念 5、#48、#49、#56 |
| 18 | 项目跨月持续 | session 事件日志、snapshot 续跑、progress file、跨会话交接 | ① | #7、Osmani 三堵墙（观察项） |

---

## 时间戳限定：这是快照，不是稳定同构

左列稳定了五十年；右列的半衰期，按洞见 1 的估计是一个模型代际。右列每个条目都应追问一句：**结构性对应，还是当前模型缺陷的临时补偿？**

- 已经滑动过的格子：context resets（#6，Opus 4.5 后删除）、plan mode 起手（Boris Cherny 本人已放弃，见观察项）
- 大概率结构性的格子：白名单/副作用分级（安全边界不随模型智商消失，#50）、评估资产（#47）、session 持久层（#7）
- 悬而未决的格子：行 7 的 Plan-before-Act——#45 预测 harness 能力终将内化进模型，规划是最先被点名的候选

所以这张表的正确用法不是背下来，而是**每个模型代际重新审一遍**：哪些格子该删（补偿失效）、哪些格子该加（新缺陷需要新补偿）、哪些格子纹丝不动（结构性）。纹丝不动的那个子集，才是"AI Agent 工程"作为学科真正的骨架。

---

## 开放问题

1. **左列的完备性**：本文用 #57 九维校验了右列（行 3），左列还没做对称校验——拿 SWEBOK 知识域过一遍，看漏了哪些传统活动（配置审计？可用性工程？）。
2. **环位的量化**：①②③ 三类行数占比会随模型能力漂移吗？如果 #45 的内化预测成立，② 类行会被吸收进模型，③ 类行占比上升——表的形态本身可以当作范式演进的测量仪。
3. **要不要升格**：这张表若配上逐格的"结构性 / 补偿性"判定与代际回访记录，可能值得做成 works/ 原创第二篇。先在此沉淀，观察它经不经得起下一个模型代际。

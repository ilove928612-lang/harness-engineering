# Loop Engineering 三源汇流：范式转移的下一层，还是 harness engineering 换皮？

> 论点：2026 年 6 月，"loop engineering" 在八天内被三个人各自独立命名，随后主导了 AI Engineer World's Fair，又被 Satya Nadella 抬成"公司论"、被 Andrew Ng 抬成"产品论"。本文判断它是什么、真正推进了仓库的哪些开放问题、以及它在哪里反而让最老的缺口更尖锐。
>
> 关联一手文献：[#56 swyx Loopcraft](../references/articles.md#article-56)、[#57 LangChain/Runkle](../references/articles.md#article-57)、[#58 Andrew Ng](../references/articles.md#article-58)、[#41 Osmani Loop Engineering](../references/articles.md#article-41)、[#42 Ronacher The Coming Loop](../references/articles.md#article-42)、[#43 官方四类循环](../references/articles.md#article-43)、[#55 Own the Outer Loop](../references/articles.md#article-55)。

---

## 一、现象：一个词的八天

不是一篇文章带火了 loop engineering，而是同一件事在极短时间里被多个独立来源同时说出来：

| 日期 | 来源 | 命名 / 说法 |
|------|------|------------|
| 06-07 | Peter Steinberger（推文） | "别再提示编码智能体，去设计提示它们的循环" |
| 06-07/08 | Boris Cherny（Claude Code 作者） | "我不再提示 Claude 了，我写循环，循环干活" |
| 06-08 | Addy Osmani | 命名《Loop Engineering》，给出五构件（#41） |
| 06-12 | swyx | 《Loopcraft: The Art of Stacking Loops》(#56) |
| 06-14 | Satya Nadella | "frontier ecosystem / token capital / learning loop"（28M+ 阅读） |
| 06-16 | LangChain / Sydney Runkle | 《The Art of Loop Engineering》四层栈（#57） |
| 06-23 | Armin Ronacher | 怀疑派回应《The Coming Loop》(#42) |
| 06-30 | Andrew Ng | The Batch 三时钟循环 + "context advantage"（#58） |
| 06-30 | Claude Code 团队 | 官方四类循环，把词固化为 shipping feature（#43） |

三个人（Osmani / swyx / Runkle）在一周内独立命名同一件事，通常是一门学科被承认、而非某人自造词的标志。仓库此前已收了 Osmani（#41/#55）、Ronacher（#42）、官方（#43），却**漏了 swyx 与 Runkle 这两个奠基命名，以及 Ng 的重述**——这正是 `deep-research-tracker.md` 反复告诫的"时间窗抓增量、回扫补存量"里的存量漏网。补齐它们，是本轮"更符合范式转移"的最直接收获。

## 二、五种切法，同一个骨架

把五篇放在一起，会发现它们不是五个理论，而是同一个骨架的五种切法：

| 来源 | 切法 | 强调 |
|------|------|------|
| Osmani #41 | 五构件（automations / worktrees / skills / connectors / sub-agents）+ 外置状态 | 工具已产品化 |
| swyx #56 | 把 loop 叠起来；往下走保可靠、往上走拿杠杆 | 层间移动 |
| Runkle #57 | 四层栈：agent → verification → event → hill-climbing | 可用原语实例化 |
| Ng #58 | 三个时钟：编码（分钟）/ 开发者反馈（小时）/ 外部反馈（天周） | 产品构建节奏 |
| 官方 #43 | 四类：turn / goal / time / proactive | 触发 × 停止分类学 |

共同骨架能压缩成一句话：**discover → act → verify → persist → repeat，状态外置，判停独立**。这恰好是 [#28 Ralph](../references/articles.md#article-28) 的 bash 循环、[concepts/03 熵管理](../concepts/03-entropy-and-garbage-collection.md) 的后台扫描、[#37 马东锡 "harness 拥有 loop"](../references/articles.md#article-37) 早就描述过的东西。**新的不是机制，是把这层机制显式抬成一个设计对象并给它命名。**

## 三、它是范式转移的第几层？——re-layering，不是 re-invention

社区叙事把它排成一条分层链：**prompt → context → harness → loop**。每一层都把上一层的产物变成新层的输入：提示词工程调输入，上下文工程管信息，harness 工程设计单个智能体的运行环境，loop 工程设计"驱动 harness 的那台机器"。

我的判断：**loop engineering 不是第五个学派，而是四学派共享的一层新战场。** 理由有二——

1. 它没有引入新的本体，只是把 [#37](../references/articles.md#article-37) 已经说透的 "model 在 loop 里、harness 拥有 loop" 从一句观察抬成一个显式的设计层。Rahul Dhar（观察项）把这层关系讲得最干脆：harness 让"单次执行"可信，loop 让"整个系统"可信——两者是分开的设计问题，不是一个的放大版。
2. 怀疑派并没有被这层新叙事解决，反而被它放大。Ronacher（#42）、AIEWF 2026 闭幕当天那场"loop 热度是否已超出实际能用"的辩论、以及 Laurie Voss "这到底是不是新东西"的追问，都指向同一件事：**给一件事起个响亮名字，不等于把它做对了。**

换句话说，loop engineering 之于 harness engineering，更像 [#41 Osmani 自己说的](../references/articles.md#article-41)"还是那个 harness，只不过它跑在定时器上、派生小帮手、自我供料"——是位置上移，不是从头发明。

## 四、它真正推进了仓库的三个开放问题

不过"换皮"的判断只对了一半。有三处，这批材料给出了仓库此前拿不到的增量：

### 增量 1：把"人类掌舵"从口号变成可操作坐标（回应洞见 5）

[cross-article-insights 洞见 5](cross-article-insights.md) 的开放问题是："当 harness 自己管 session、自己 provision，'人类掌舵' 具体意味着什么？" 三篇合起来第一次给了可操作的答案：

- **Ng 的 "context advantage" 取代 "taste"（#58）** 是这里最锋利的一刀。"品味"是先天的、不可教的，说了等于没说；"上下文优势"是**可编码的**——把你比模型多知道的东西（用户约束、合规、品牌、领域暗知识）写进循环。"只要人类知道 AI 不知道的东西，就需要 human-in-the-loop 注入那份知识。" 这直接把神秘的掌舵翻译成一条工程指令：找到你的 context advantage，把它变成 spec / eval / 约束。
- **Osmani 的内环/外环（#55）** 给了掌舵的**位置**：智能体跑内环，人拥有外环（问责）。
- **swyx 的"往上走一层拿杠杆"（#56）** 给了掌舵的**方向**：模型变强时，人应该主动往更外层的 loop 迁移，而不是守在原地。

三者拼起来正好回答洞见 5 结尾的 "OKR 化" 猜测：人类不是被移出回路，而是沿着 loop 栈向上移动，掌舵的对象从"这一步对不对"变成"目标/分配/验收标准对不对"。这与 [#45 Weng "人类应在栈上向上移动，而不是被移出回路"](../references/articles.md#article-45) 完全同向。

### 增量 2：给 meta-harness / self-harness 一个通用的循环位置——以及一条诚实性约束（回应洞见 4）

Runkle 的第四层"hill-climbing loop"（#57）把仓库里散落的一堆东西收进同一个位置：[#27 LangSmith Engine](../references/articles.md#article-27)、[#44 Self-Harness](../references/articles.md#article-44)、[#24 AHE](../references/articles.md#article-24) 都是"读生产轨迹→自动改写 harness"的实例。更重要的是她加的那条限定，正好戳在仓库的[评估之踵（洞见 4）](evaluation-elephant-in-the-room.md)上：

> "没有可信的验证（loop 2），就没有安全的爬山（loop 4）。一旦 agent 能在不改进真实结果的前提下刷高分，爬山就退化成带额外步骤的 reward hacking。"

这把洞见 4 从"行为正确性难验证"推进了一步：**自动改进不是绕过评估缺陷，而是放大它。** 一个可被刷分的 eval，接上 hill-climbing loop 后，会被系统性地、自动地推向那个错误的峰。这与 [#45 Weng "奖励劫持防线必须在演化回路之外"](../references/articles.md#article-45)、[#25 Overeager "提示声明反而降低边界推断"](../references/articles.md#article-25) 是同一条警报的三个音。

### 增量 3：把范式转移抬到组织层（回应洞见 3 与 7）

Satya Nadella 的"frontier ecosystem"（观察项）不是工程文，但它把 loop 抬成了**公司论**：learning loop 是"hill-climbing machine"，human capital × token capital 在其中复利，"这条 loop 成为公司新的 IP"。它的爆点是一句可证伪的断言——"你可以换掉底层通用模型而不丢公司老兵经验"——恰好回应了[洞见 3（model-harness 耦合/锁定）](cross-article-insights.md)和[洞见 7（单一栽培风险）](cross-article-insights.md)：**拥有自己的 loop，是对抗模型锁定的护城河。** 谁把学习沉淀进自己的循环，谁在模型被换/被断供时才不受制于人（The Batch 同期就记录了 Claude Fable 5 被政策性断供的真实案例）。

## 五、对四学派的更新

| 学派 | loop engineering 对它做了什么 |
|------|------------------------------|
| 约束派（OpenAI/HumanLayer） | 把约束外推到"外环"：back-pressure 从验证门升格为自主权阀门（#55） |
| 控制论派（Fowler/Böckeler） | 在前馈/反馈闭环上再叠一层**元反馈**（hill-climbing = 用反馈改回路本身，#57 loop 4） |
| 架构派（Anthropic） | loop 是"多大脑多双手"的调度外壳；dynamic workflows（#36）是模型自写 loop |
| 怀疑派（YDD/METR/Ronacher） | **批评在 loop 层更尖锐**：verifier 是瓶颈、comprehension debt 涨得更快、"完成"信号更空 |

结论：loop 不是第五学派，是四学派的新战场。这与 Fowler Fragments 里 Kief Morris 的统一叙事（"所有争论都是——交给智能体的工作单元怎么设定"）在更高一层重合：loop engineering 就是在设计"工作单元如何被反复地发现、执行、验收、交接"。

## 六、一个还没人正面对撞的问题

把 swyx 的"往上走一层拿杠杆"和 Böckeler 的["行为 harness 是房间里的大象"](evaluation-elephant-in-the-room.md)正面撞一下，会得到一个不太舒服的推论：

> **loop engineering 的杠杆增益，可能与仓库最老的缺口（行为正确性验证）成反比。**

因为"往上走一层"= 把更多判断权交给自动判停（loop 2 的 verifier）。在可形式化验证的域（编译、类型、测试、[#46 Aria 的 Coq 内核](../references/articles.md#article-46)、[#54 DSL 的解析器](../references/articles.md#article-54)），verifier 近乎完美，往上叠循环非常安全——[#49 Carlini "验证器必须近乎完美，否则 Claude 会去解决错误的问题"](../references/articles.md#article-49)就是这条的正面注脚。但在需求模糊、正确性难形式化的域（产品判断、设计、安全语义），verifier 本身是弱的、可被刷的——此时"往上走拿杠杆"是在**用自动化加速地把系统推向一个 confidently-wrong 的峰**。

所以 swyx 的"上一层拿杠杆"不是无条件的建议，它有一个隐含前提：**你所在的域的 verifier 有多可信，你就能安全地往上走多少层。** Ng 的 context advantage 正是补这个前提的——人类要注入的，恰恰是让 verifier 变可信的那部分领域知识。这两篇放在一起，才是完整的一句话；单看任何一篇都会误导。

## 七、把镜子转向仓库自己

本仓库的 [`curate-research` skill](../.claude/skills/curate-research/SKILL.md) 本身就是一条 loop：discover（调研）→ act（翻译）→ verify（并行评审 + `scripts/check-consistency.sh` 的 C1–C12）→ 🚧人类闸门🚧 → persist（收录）。用 Runkle 的四层栈量一下：

- loop 1（agent）✅、loop 2（verification）✅ 有确定性护栏、loop 3（event，本次由人手动触发）⚪
- **loop 4（hill-climbing）缺席**：没有谁自动分析"这个仓库过去哪些收录判断错了 / 哪些观察项一直没转正 / 哪些计数漂移反复出现"，再回去改 skill 本身。

按 Runkle 的依赖链，这其实是对的顺序——**在 verification（C1–C12 + 人类闸门）足够可信之前，先别急着上 hill-climbing**，否则就是给这个仓库自己接上一台 reward-hacking 机器。这一条，既是本次调研的结论，也是留给下一次的问题：这个仓库的 loop 4，应该在什么时候、以什么形态，安全地接上来？

---

## 开放问题

1. loop engineering 与 harness engineering 的边界，是真实的工程分层，还是叙事分层？（Rahul Dhar 说是两个设计问题，Laurie Voss 存疑）
2. "verifier 可信度决定可安全上叠的层数"这条推论，能不能量化成一个类似 [#35 harness 效应](../references/articles.md#article-35)的可测指标？
3. 如果 context advantage 是人类不可替代的核心，那它会不会也随模型见过越来越多领域而被逐步吃掉？（对照 [#45 Weng "harness 终将内化"](../references/articles.md#article-45)的预测）
4. 本仓库该不该、以及何时该，给自己接上 loop 4？

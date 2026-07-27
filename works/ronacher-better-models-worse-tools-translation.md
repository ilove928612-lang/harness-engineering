---
title: "更好的模型：更差的工具（Better Models: Worse Tools）"
sourceTitle: "Better Models: Worse Tools"
sourceUrl: "https://lucumr.pocoo.org/2026/7/4/better-models-worse-tools/"
sourceAuthor: "Armin Ronacher（Flask / Jinja 作者、Sentry 创始人，编码智能体 Pi 开发者）"
sourcePublishedAt: "2026-07-04"
sourceSiteName: "Armin Ronacher's Thoughts and Writings"
summary: "Anthropic 的新模型（Opus 4.8、Sonnet 5）在非 Claude Code 形状的编辑工具上，比它们的老版本更容易发出畸形的工具调用——在正确的 oldText/newText 之后凭空追加发明的键。Ronacher 追踪到的原因不是模型变笨，而是后训练：Claude Code 客户端会静默修复各种脏调用，在这样一个宽容环境里做 RL，模型学到的是'多加个字段无所谓'。结论是工具 schema 不是中立契约，越训得好的模型对主导 harness 的先验越强、对替代 schema 的反抗越凶。"
sourceLanguage: "en"
language: "zh-CN"
translationMethod: "人工整理逐段翻译（cloud agent，对照原文全文）"
sourceFigureCount: 0
sourceFigureAudit: "2026-07-27 对照原文 Markdown 源（同 URL 的 .md 版）逐段核对：全文只有代码块，无任何图片"
---

# 更好的模型：更差的工具

过去两天，[Pi 上一个非常古怪的问题](https://github.com/earendil-works/pi/issues/6278)把我拽进了一个兔子洞。简短版本是：新版 Claude 模型有时会带着**凭空发明的额外字段**去调用 Pi 的编辑工具，位置在嵌套的 `edits[]` 数组里。而且不是 Haiku 或者什么小模型，是 Opus 4.8。编辑内容本身通常是对的，但参数与 schema 不匹配——模型编出了不存在的键，于是 Pi 拒绝这次工具调用并要求重试。

单是这件事并不算太意外，模型偶尔就是会发出畸形的工具调用，小模型尤其如此。让我吃惊的是**这个问题在越新的 Anthropic 模型上越严重**：Opus 4.8 和 Sonnet 5 都有，更老的那些一个都没有。换句话说，这个家族里的 SOTA 模型，在这个特定的工具 schema 上，比它们的兄长更差。

顺便说一句 Fable：我故意没测它，因为不确定他们跑的分类器会不会把我悄悄降级到 Opus。

## 工具调用就是文本

如果你没怎么钻研过 LLM 工具调用的内部机制，需要理解的关键点是：**工具调用没有魔法，它用的是相当粗糙的带内信令。** 模型收到一份转录、一段系统提示词和一张可用工具清单。服务端把这些嚼成一个带特殊标记 token 的大提示词。因为模型是在这种格式的样例上训练与强化过的，所以在生成过程中的某个时刻，它吐出一段被 API 或客户端解读为"用这些参数调用这个工具"的东西。

对一个文件编辑工具来说，预期的调用载荷可能长这样：

```json
{
  "path": "some/file.py",
  "edits": [
    {
      "oldText": "text to replace",
      "newText": "replacement text"
    }
  ]
}
```

harness 随后校验参数、执行编辑、把结果喂回模型。如果校验失败，模型会看到一个错误，通常再试一次。

Anthropic 的模型具体怎么做这层格式化并不公开，但有人套出过 "ANTML" 标记，而这些标记有时也会漏进公开材料里。据我所知，上面那次调用从模型里序列化出来大致是这样：

```xml
<function_calls>
  <invoke name="edit">
    <parameter name="path">some/file.py</parameter>
    <parameter name="edits">
[
  {
    "oldText": "text to replace",
    "newText": "replacement text"
  }
]
    </parameter>
  </invoke>
</function_calls>
```

这里有一点值得注意：这东西**看起来像 XML，但并不真的是 XML**。它只是他们觉得便于分词与训练的一种形式。另一点是：**基础的顶层字符串参数是内联出现的，而对象数组是通过 JSON 序列化实现的。** 虽然我不完全确定内部就是这么工作的，但有若干迹象表明这个描述不算太离谱。这一点后面会变得重要。

要让模型产出这样一个结构，有两种非常不同的路子：

1. 你可以要求模型产出符合某个 schema 的合法 JSON，然后事后校验。
2. 你可以约束采样器，让不合法的 JSON、甚至不合法的 schema 形状**根本采样不出来**。

第二种就是人们常说的语法感知（grammar-aware）解码或受限解码：采样器把会违反语法的 token 屏蔽掉。如果模型此刻正在一个 JSON 对象内部，而 schema 规定只允许 `oldText` 和 `newText`，采样器就可以阻止它吐出 `"in_file"` 或 `"type"`。语法感知解码既能用来约束"必须是语法合法的 JSON"，也能用来强制特定的枚举值或键名。

**在没有任何约束的情况下，模型只是在遵循一个学来的惯例。**

## 故障

Pi 的编辑工具支持在一次调用里做多处精确字符串替换，这就是参数里有 `edits` 数组的原因。在失败的案例里，模型产出的条目长这样：

```json
{
  "oldText": "...",
  "newText": "...",
  "requireUnique": true
}
```

或者这样：

```json
{
  "oldText": "...",
  "newText": "...",
  "oldText2": "",
  "newText2": ""
}
```

在反复试验中，我见到了一整个动物园的发明出来的尾随键：`type`、`id`、`kind`、`unique`、`requireUnique`、`matchCase`、`in_file`、`forceMatchCount`、`children`、`notes`、`cost`、`oldText2`、`newText2`、`oldText_2`、`newText_2`，甚至还有一个出现在 edit 对象内部的 `event.0.additionalProperties`。

最让人恼火的地方在于：**我检查过的那些非法调用里，真正的 `oldText` 与 `newText` 载荷是逐字节正确的。** 模型事实上已经产出了正确的调用，然后在对象末尾加了些废话。

这个故障还高度依赖上下文。像"编辑这个文件"这样一句全新的单轮提示词，在我这儿完全复现不出来；而一段智能体式的历史——模型读过文件、诊断过问题，然后组装一次多行编辑——就能复现。更烦人的是，并不是所有转录都会出现这个行为，事实上我得靠 [Petr Baudis](https://github.com/pasky) 的转录才复现得出来！在那位用户的会话里，继续会话会让 Opus 4.8 有大约 **20%** 的失败率。**把历史中的 thinking 块剥掉，失败率减半；打开严格（strict）工具调用，在我这几轮里直接归零。**

## 为什么在变差

我最强的假说是：这不是随机的劣化，而是**训练产物**。

更老的 Anthropic 模型训练时，也是在一些工具上训的（其中一些有文档）。但那时的训练还没有一个像 Claude Code 这样"已经发给用户的 harness"作为明确目标。现代 Anthropic 模型很可能不同：它们的后训练里包含 Claude Code，或者一个长得非常像它的 harness。模型学到了在那个环境里一次成功的工具调用长什么样，**同时也学到了那个环境会容忍哪些错误**。

Claude Code 自己的工具相对扁平。它常规的编辑工具不是 Pi 那种嵌套的 `edits[]` 形状，而更接近 `file_path`、`old_string`、`new_string` 加一个可选标志（`replace_all`）。看看 Claude Code 的客户端很有启发：里面有针对畸形工具使用的重试路径、参数别名、类型强制转换、Unicode 修复，以及**对未知键的过滤**。换句话说，Anthropic 自己的客户端似乎预期并接受相当程度的脏数据，而且**多半是静默修复的**。

如果强化学习是在这样一个 harness（或它的仿真）里发生的，那么**略微畸形的工具调用照样能完成任务、照样能拿到奖励**。harness 把错误完全吸收掉了，于是几乎没有任何梯度去反对"编一个别名""加一个多余字段""用一个相近的参数名"。

更糟的是，模型可能变得**极度适配 Claude Code 那个规范的编辑工具形状**。另一个 harness 可以给出语义意图相同、但 schema 不同的工具，而这样的工具会越来越分布外。**训得更好的那个模型，可能反而跟你抗得更凶，因为它的先验更强。**

这算不上太意外，但相比几个月前确实是个变化。Opus 4.5 刚发布时，它对别的编辑工具适应得非常好。当时我还相当确信我们走在一条好路上：只要指令写得好，模型会越来越愿意去适应任何形状的工具。

现在我对我们正走的这条轨道有点担心。**替代性的工具 schema 可能不只是"不熟悉"，它们还可能被后训练隐性地惩罚了**——因为那个后训练在为一套特定的、宽容的工具生态做优化。而**那套生态是没有文档的**。虽然有一个[有文档的文本编辑器工具](https://platform.claude.com/docs/en/agents-and-tools/tool-use/text-editor-tool)，但你会发现 Claude Code 事实上并不遵循那个格式。Claude Code 内部到底在做什么（一个闭源 harness）对你是隐藏的。

## 脏数据 harness

Claude Code 显然是闭源的，但我们可以看压缩后的代码，大致了解它做了什么。老实说，它对进来的数据非常宽容。

首先，Claude Code 会检查模型的可见文本里有没有漏出来的 `<invoke` 标记。它还会在这种情况发生时上报一些遥测，并用自己的状态机把这类坏调用推回给模型重试。

它有显式的 Unicode 转义修复，会修好字符串值里破损的 `\uXXXX` 序列和孤立代理项。它还为每个工具准备了参数别名，比如 `Edit` 接受 `old_str`（大概是从模型还在按官方文档的文本编辑器工具训练的年代留下来的）、schema 里较新的 `old_string`、`new_str` / `new_string`、用 `path` 作为 `file_path` 的别名，还有更多。

它还会**静默过滤掉意料之外的键**，并且**没有使用 `strict` 模式**。`strict` 模式的问题是，Anthropic 对工具定义施加了复杂度上限，超出会导致 API 请求失败——大概这就是 Claude Code 不去尝试它的原因。

## 严格性

这个问题会不会也出现在别的 harness 上？Anthropic 有一个大麻烦：**模型完全闭源，harness 也是。** Codex 的模型同样闭源，但至少 harness 不是。我们还有 [gpt-oss](https://github.com/openai/gpt-oss)，多少有点意思。这些模型被明确训练去使用 OpenAI 的 [harmony](https://github.com/openai/harmony) 响应格式，而且有大量文档，至少告诉了我们 OpenAI 的人是怎么想这件事的。

harmony 把频道（channel）与工具调用内容类型变成了提示词格式的一部分。一次函数调用可以长这样：

```
<|start|>assistant<|channel|>commentary to=functions.get_weather
<|constrain|>json<|message|>{"location":"San Francisco"}<|call|>
```

关键位是 `<|constrain|>json`。**模型可以在带内声明这段消息体是 JSON，推理栈就能利用这个边界，为工具调用的正文切换到 JSON 受限采样。** 大概 Anthropic 的模型里也发生着一部分类似的事，至少在 `strict` 模式下我猜是这样。

harmony 里的这个标记帮助采样器判断何时需要用特定语法来采样，而且因为它是转录的一部分，这件事做起来相当容易。对于托管的 GPT 模型，还有一个选项是为自定义工具提供 [LARK](https://lark-parser.readthedocs.io/en/latest/grammar.html) 语法。

Anthropic 看起来与此不同，不过也许不是完全不同。如果对象数组确实像它表现的那样被表示为 JSON，那么模型就得在工具参数**内部**写 JSON。**这里大概正在发生某种基本的语法受限采样，这也许能部分解释那些多出来的键。** 对于一个嵌套的数组参数，这段 JSON 里包含着**被转义的多行文件内容、塞在字符串字面量里、又塞在一个标签里**。那些意料之外的、编造出来的键，恰好出现在这项任务熵最高的那一点：**在收尾一个长达数百 token 的转义 `newText` 字符串之后，模型必须决定下一个是 `}` 还是 `, "..."`。**

Opus 4.8 和 Sonnet 5 似乎对"一次编辑工具调用应该长什么样"抱有强得多的先验，而那个先验看起来就是 Claude Code 的编辑 schema：一对扁平的 old/new 字符串，外加可选的 `replace_all` 标志。我的猜测是，Opus 学到了"编辑操作可以多一个可选字段"，但在 Pi 那种嵌套的 `oldText` / `newText` 形状下，它**没有一个受过训练的名字可用**，于是每次现场采样一个听起来合理的名字——这也解释了为什么这些失败产出的是几十个随机键，而不是一个稳定的别名。

既然 Anthropic 的 `strict` 模式看起来能修好这个问题，我推测服务端会拒绝采样任何不被 JSON schema 结构允许的键。这同时也解释了为什么开启严格模式时，他们要对工具定义的复杂度设限。

到目前为止，我测过的 Codex 模型没有表现出这类退化。除了还没拿到访问权限的 5.6 之外，我测了所有能拿到的版本。

## 这对 harness 意味着什么

令人不适的教训是：**工具 schema 不是中立的**，至少在 Anthropic 的模型上不是。我们喜欢假装 schema 是一份抽象契约、模型是一个会遵守它的通用推理器，但对某些工具而言，这可能已经不再成立。

工具 schema 位于分布中的某处：有些形状接近模型后训练时见过的东西，有些则相距甚远。有些对厂商隐藏的编码方式来说很容易（比如 ANTML 里的顶层属性），有些则要求模型在长长的多行字符串之后、在嵌套数组里写出大段转义 JSON 对象。**模型可以聪明到理解这个 schema，同时依然不擅长在压力下精确采样出它的形状。**

如果这类模型行为持续下去，我很好奇它对 harness 意味着什么。显然，你可以在 Anthropic 那边打开 `strict` 采样，问题应该就消失了。但另一方面，模型有这种行为本身，就显示了强化学习对它们的影响有多大。**如果你想要模型的最佳性能，跟这个先验硬碰硬多半是徒劳的。**

眼下的现实是，Claude Code 不开源，我们也无从知道他们的 RL 环境里到底在做什么。**我们不能假设"在 Claude Code 里训出来的行为"会干净地迁移到你的工具上，除非你的工具与它高度相似。后训练越是集中在某一个主导 harness 内部，其他每一个 harness 就越是要继承它的怪癖。**

我过去对严格的语法受限工具调用更持怀疑态度，因为受限解码可能带来质量上的取舍。我仍然认为这在一般意义上可能成立，但**这个 bug 显著改变了我的先验**。如果最新的模型在解决任务上变得更强、同时在忠实地吐出替代工具 schema 上变得更弱，那么 **harness 就必须在别的地方拿到更硬的保证**。

如果你想了解更多，或者想讨论，可以读一读 [Pi 追踪器上的这个 issue](https://github.com/earendil-works/pi/issues/6278)。

---

> 译注：本文与本仓库 [references/articles.md](../references/articles.md) 中的 #60（Cursor《持续改进我们的 agent harness》）互为正反面——Cursor 的对策正是"给每个模型配它训练时用的工具格式"（OpenAI 走 patch 格式、Anthropic 走字符串替换），因为"给它不熟悉的那个会多花推理 token 并产生更多错误"。文中对 Claude Code 客户端内部行为的描述，可与 #30（Claude Code 源码泄漏事件）对照阅读。

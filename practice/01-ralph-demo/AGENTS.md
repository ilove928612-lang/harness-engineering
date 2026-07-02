# practice/01-ralph-demo/ — Ralph Orchestrator 编排循环实验

用 Ralph Orchestrator v2.8.1 + Claude Code 后端从零完成一个编码任务（CLI word counter），观察帽子系统、背压门控、迭代循环、持久记忆的实际运行。完整实验记录见 [README.md](README.md)。

## 文件清单与来源

| 文件 | 来源 |
|------|------|
| [README.md](README.md) | 实验一手记录（目标 / 步骤 / 循环过程 / 产出 / 概念映射） |
| [PROMPT.md](PROMPT.md) | 实验中人类唯一的产出，原样归档 |
| [ralph.yml](ralph.yml) | 运行配置，按 README 记录的核心配置归档 |
| [wc.py](wc.py) | 智能体产出，README 正文引用的源码原样落盘（引用块 41 行；README 标题与运行输出记录为 49 行，差异属实验记录内部出入，档案以引用块为准） |
| [test_wc.py](test_wc.py) | **复原件**：原始测试文件未存档，按 README 的 7 项测试矩阵重建 |

> 原始运行发生在 `/tmp/ralph-demo`（ephemeral 路径）。落盘这些文件是事后对"仓库即记录系统"的补课：不在仓库里的东西，对智能体不存在。

## 如何复验

```bash
cd practice/01-ralph-demo && python3 -m pytest test_wc.py -v   # 7 项测试矩阵
python3 wc.py wc.py                                            # CLI 输出示例
```

如需复跑整个编排循环（需要 Ralph CLI 与 Claude 后端）：

```bash
npm install -g @ralph-orchestrator/ralph-cli
mkdir -p /tmp/ralph-demo && cd /tmp/ralph-demo
cp <本目录>/PROMPT.md . && ralph init --backend claude
ralph run -c ralph.yml -H builtin:code-assist
```

## 下一步

- 工具主张与失效场景：[tools/harnesses/ralph-orchestrator.md](../../tools/harnesses/ralph-orchestrator.md)
- 实验反思（Critic Hat 仍是 LLM 的局限）：[thinking/evaluation-elephant-in-the-room.md](../../thinking/evaluation-elephant-in-the-room.md)

# practice/02-workflow-loop-routing/ — 三方闭环自动路由实验

三套方法论 skill（superpowers × vloop × ponytail）共存时如何避免抢任务、零命令自动触发。核心产物是 workflow-loop 路由 skill + 防打架五规则。

## 文件清单

| 文件 | 来源 |
|------|------|
| [README.md](README.md) | 实验记录（问题 / 解法 / 防打架五规则 / 设计要点） |
| [SKILL.md](SKILL.md) | workflow-loop 路由 skill 原件（Hermes 端实装，5 端可复用） |

## 如何复验

1. 三套 skill 就位：superpowers（14 skill）+ vloop + ponytail（hook）
2. 装上 workflow-loop（skills 目录）
3. 说“实现 X”（小任务）→ 应走 superpowers 链；说“跑完再叫我”（大任务）→ 应走 vloop 协议

## 下一步

- 5 端同构安装 workflow-loop
- 实测验证路由正确性

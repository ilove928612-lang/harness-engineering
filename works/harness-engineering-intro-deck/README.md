# 驭缰工程 · 项目介绍 PPT 与海报

用 [open-kimi-ppt skill](https://github.com/deusyu/open-kimi-ppt-skill)（deusyu fork）为本仓库生成的一套可编辑演示物料：**10 页介绍 PPT** + **1 页竖版海报**。每份交付物都包含两种形态——可继续编辑的 PPTD 项目（YAML 源）和开箱即用的 PPTX 成品（嵌入字体 + 淡入淡出切换）。

> 内容里的篇数 / 计数均为 **2026-08 快照**，最新进度以仓库 README 与 `references/articles.md` 为准。

## 目录

| 路径 | 说明 |
|------|------|
| `deck/deck.pptd` + `deck/pages/` | PPT 的 PPTD 源（10 页，16:9） |
| `deck/deck.pptx` | PPT 成品（嵌入字体，可直接演示） |
| `poster/poster.pptd` + `poster/pages/` | 海报的 PPTD 源（1 页，3:4 竖版） |
| `poster/poster.pptx` | 海报成品 |
| `poster/style.md` | 海报的设计简报（按 skill 的 general-poster 规范） |

## 页面结构（deck）

封面（缰绳曲线主视觉）→ 01 范式转变 → 02 六大核心概念 → 03 OpenAI 实证数据 → 04 学习闭环 → 05 仓库地图 → 06 机械化检查 C1–C13 → 07 仓库即 harness（自指）→ 08 研究资料库 → 封底。

## 视觉系统

- 配色：暖纸底 `#F5F1E8` × 深墨 `#1F1C17` × 缰绳橙红 `#C2481D`（唯一强调色）
- 字体：标题/数字 **得意黑**、正文 **MiSans**、拉丁 **Liter**（三者均已嵌入 PPTX；得意黑为斜体-only 设计）
- 视觉 DNA：一条「缰绳」曲线贯穿封面与封底——起点墨色锚点是人类，箭头指向智能体

## 如何继续编辑

```bash
npx open-kimi-ppt-skills serve
# 打开 http://127.0.0.1:55173/ ，选择 deck/ 或 poster/ 目录即可在浏览器中编辑并手动导出 PPTX
```

或直接改 `pages/*.page`（YAML）后重新导出：

```bash
python3 ~/.agents/skills/open-kimi-ppt/scripts/export_pptx.py deck/deck.pptd --output deck/deck.pptx --force
```

## 生成说明

- 生成时间：2026-08；工具链：open-kimi-ppt skill（PPTD DSL + Kimi 公开编辑器的浏览器端 OOXML writer）
- 数据事实来源：仓库 README、`practice/01-ralph-demo/`、`references/articles.md` 与 [OpenAI 原文](https://openai.com/zh-Hans-CN/index/harness-engineering/)，未虚构数据
- 已做视觉质检（skill 的 export_images 整页核查）与 PPTX 校验（ZIP 完整性、每页根级 fade 切换、字体嵌入部件）
- 一个已知取舍：标题字体原选阿里妈妈数黑体，但官方 writer 不支持嵌入该字体，为保证"任何机器打开都一致"换成可嵌入的得意黑

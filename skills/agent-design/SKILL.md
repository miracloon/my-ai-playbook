---
name: agent-design
description: Use when designing a new Hermes agent/profile in the current station. Produces reviewable design records and compiled runtime drafts through structured alignment and implementation strategy.
---

# Agent Design

设计本驻地新 Hermes agent / profile。从意图对齐开始，经过画像讨论和实现策略推演，产出设计草稿和可直接使用的运行时产物。

## 核心概念

| 概念 | 含义 |
|------|------|
| 功能 | 用户视角：agent 能帮用户完成什么任务 |
| 能力 | 技术视角：agent 靠什么手段完成任务（不展开实现细节） |
| 草稿 | 设计工作区交付的文件（profile.md / operations.md / decisions.md） |
| 产物 | 最终编译出的 SOUL.md 和 AGENTS.md，下游直接使用 |
| 硬约束 | 通过 Hermes 命令行控制（skill / 工具启停等） |
| 软约束 | 通过提示词控制（行为原则、表达基线等） |

## 工作契约

- 只设计本驻地新 agent / profile
- 围绕用户想法逐项讨论，不压成一次性问题清单
- 用场景语言和用户讨论，不抛架构术语
- 草稿保留取舍和依据；产物只保留下游需要的内容
- 落地由用户主动推进

## 任务目录

```text
tasks/agent-design/{agent_name}/
├── profile.md          # 定位、功能、能力、边界、工作流程
├── operations.md       # 权限、配置、落地配置项
├── decisions.md        # 关键决策、阻塞推演方案、未决问题
├── secret.md           # env 密钥（仅 key，用户补充 value）
└── compiled/
    ├── SOUL.md
    └── workspace-AGENTS.md  # 仅在需要时创建
```

## 流程

| 阶段 | 内容 | 推进信号 |
|------|------|----------|
| 1. 对齐与画像 | 确认方向 → 深入讨论骨架 | 功能骨架流程图获用户认可 |
| 2. 实现策略 | 阻塞推演 → 权限 → 配置 → 草稿 → 编译质检 | 实现策略流程图获用户认可 + 编译质检通过 |
| 3. 落地 | 按 SOP 执行 Hermes 平台操作 | — |

### 阶段1：对齐与画像

#### 1.1 初步对齐

理解用户的原始想法，确认方向没有被误读。

需要确认：用户想要什么、为什么需要、哪些明确哪些模糊、有哪些歧义和隐含期待。

初步对齐只负责方向正确，不展开结构。

#### 1.2 深度对齐

在方向正确的基础上，逐项讨论 agent 的骨架，直到结构化可审查。

核心要求：**已讨论 ≠ 仅覆盖**。每个骨架话题必须真正讨论清楚，不能提了一遍就推进。

**骨架话题**（必须讨论清楚）：

- 定位：这个 agent 是什么角色
- 功能：能帮用户完成哪些任务
- 能力：具备哪些手段（不展开实现细节）
- 功能边界：不做什么
- 工作流程路由：主干路径和分支

**辅助话题**（自然浮现，不强制单独展开）：

- 使用场景 / 场景推演
- 端点（输入输出）
- 生态关系
- 表达与人格（默认跳过，用户需要时展开）

**信息去向**：

| 信息 | 草稿 | 产物 |
|------|------|------|
| 定位、功能、能力 | 写入 | 编译进产物 |
| 功能边界 | 写入 | 慎重：进产物易多说多错，质检时特别关注 |
| 工作流程路由 | 写入 | 按需精简后编译 |
| 使用场景、场景推演 | 按需写入 | 按需 |

**推进信号**：骨架讨论清楚后，呈现功能骨架流程图，用户认可即可进入阶段2。

参考：`references/alignment.md`

### 阶段2：实现策略

#### 2.1 能力阻塞推演

对每条有讨论价值的能力，代入任务场景做可行性推演：

- 有什么阻塞？需要什么准备 / 工具 / 条件？
- 用什么方案解决？
- 可以用哪些现有 skill 完成？

无阻塞、方案明确的能力直接跳过。

推演目的是让用户在 agent 创建前明确每条能力的准备和途径。

**推进信号**：呈现实现策略流程图，用户认可后继续。

参考：`references/capability-analysis.md`

#### 2.2 权限判断

从阻塞推演中提取权限需求，收紧式预备：非必要不开启。

- 硬约束：通过 Hermes 命令行控制的 skill、工具启停
- 软约束：通过提示词传达的行为边界，放入产物的行为原则模块

参考：`references/permissions.md`

#### 2.3 配置对齐

带默认值推进，用户无反应按默认记录。注入适用的用户通用约束。

参考：`references/config-and-deployment.md`、`references/user-constraints/overview.md`

#### 2.4 草稿落文

将讨论成果整理到任务目录的三个草稿文件中：

| 文件 | 内容 |
|------|------|
| `profile.md` | 定位、功能、能力、边界、工作流程 |
| `operations.md` | 权限清单、配置项、落地配置 |
| `decisions.md` | 关键决策、阻塞推演方案、未决问题 |

#### 2.5 编译 + 质检

从草稿编译运行时产物：

- `compiled/SOUL.md`
- `compiled/workspace-AGENTS.md`（仅在需要时）

编译后执行质量检验。

参考：`references/compilation.md`

### 阶段3：落地

按 Hermes 内置说明书和部署 SOP 执行平台操作。

参考：`references/config-and-deployment.md`

## Reference 路由

| 需要 | 读取 |
|------|------|
| 对齐引导、话题覆盖、收敛标准 | `references/alignment.md` |
| 能力阻塞推演方法 | `references/capability-analysis.md` |
| 权限收紧逻辑、硬/软约束 | `references/permissions.md` |
| 配置默认值、部署 SOP | `references/config-and-deployment.md` |
| 用户通用约束（记忆、环境等） | `references/user-constraints/overview.md` |
| 编译原则、质量检验 | `references/compilation.md` |

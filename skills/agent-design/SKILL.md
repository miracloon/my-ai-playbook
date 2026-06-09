---
name: agent-design
description: Use when designing or redesigning a Hermes agent/profile in the current station. Produces a reviewable design record and runtime drafts, with lightweight landing preferences for optional platform execution.
---

# Agent Design

设计或重塑本驻地 Hermes agent / profile。

本 skill 负责把用户意图整理成可回溯的设计稿，并同步编译运行时草案。Hermes 平台操作本身按内置 `hermes-agent` 说明书、Hermes 文档或 CLI help 执行；本 skill 只补充用户偏好和少量落地提醒。

## 适用范围

| 适用 | 不适用 |
|------|--------|
| 新建 agent / profile 的设计 | 当前业务任务执行 |
| 已有 agent / profile 的身份、职责、边界、能力或表达方式重塑 | 直接执行 Hermes 平台操作 |
| 为目标 agent 规划 skill、权限、运行入口和 workspace 入口 | 跨驻地 profile 操作 |
| 产出可审阅、可回顾、可落地的设计材料 | 为目标 agent 直接实现复杂业务 skill |

## 工作契约

- 只设计本驻地 agent / profile。
- 围绕用户想法逐项讨论，不把画像完善压成一次性问题清单。
- 在同一轮产出中形成 `tasks/agent-design/{agent_name}/design.md` 和运行时草案。
- 对用户使用场景对齐，不把架构问题直接抛给用户。
- 设计稿可以保留取舍和依据；运行时草案只保留下游需要读到的内容。
- 如果用户要求继续落地，直接按 Hermes 内置说明书和本 skill 的轻量落地偏好执行。

## 工作阶段

### 1. 意图对齐

理解用户的原始想法，确认没有误读。

重点是抓住用户真正想要什么、为什么需要这个 agent，以及当前输入中有哪些歧义、模糊、缺口或隐含期待。

### 2. 画像完善

围绕目标 agent 逐项补全画像。使用场景、职责范围、表达方式、生态关系、成功标准等可以多轮讨论，不要压成一次提问。

如果是修改已有 profile，只对受影响部分重新对齐；常见变化包括身份、定位、能力、边界、表达、workspace 规则、工作流程、skill、权限或配置。

### 3. 实现策略梳理

在理解画像后，主动整理适合 Hermes 的实现方式：

- SOUL 应承载什么。
- 是否需要 workspace `AGENTS.md`。
- 是否适合使用内置 skill、cron、gateway 常驻、外部入口或其他 Hermes 能力。
- 权限和工具需要保留、收紧或额外授权什么。

这里由核心主管把用户意图翻译成 Hermes 中可运行的方案，不要求用户直接选择架构。

### 4. 配置对齐

只讨论落地所需配置事实：profile 名、workspace 目录、gateway / channel、是否常驻、默认 provider / model、env / credential、需要安装的内置 skill。

### 5. 写入设计稿并编译草案

将已收敛内容写入 `tasks/agent-design/{agent_name}/design.md`，并同步编译：

- `compiled/SOUL.md`
- 必要时 `compiled/workspace-AGENTS.md`

编译时遵循 `design-quality.md`，避免模板化、上游噪声下传和目标 agent 不可见概念。

### 6. 是否落地

询问用户是否执行平台操作。若执行，按 Hermes 内置说明书、Hermes 文档或 CLI help 落地；创建 agent 时遵循 `permissions-and-skills.md` 中的轻量落地提醒。

## Reference 路由

| 需要 | 读取 |
|------|------|
| 建立任务目录、维护设计稿 | `references/task-folder.md` |
| 用户对齐、场景探索、画像完善和收敛标准 | `references/alignment.md` |
| 从设计稿编译 SOUL / AGENTS 草案 | `references/soul-compilation.md` |
| 交付前检查、避免模板化和上游噪声下传 | `references/design-quality.md` |
| 权限、toolset、内置 skill 选拔和轻量落地提醒 | `references/permissions-and-skills.md` |

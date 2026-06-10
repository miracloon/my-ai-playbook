# Task Folder

每个 agent 设计任务使用独立目录：

```text
tasks/agent-design/{agent_name}/
├── design.md
└── compiled/
    └── SOUL.md
```

`compiled/workspace-AGENTS.md` 只在目标 profile 需要专门设计 workspace 入口时创建。

## design.md

`design.md` 是设计侧事实源，允许保留推导、取舍和未决问题。它不直接作为运行时上下文给目标 agent 使用。

建议结构：

```md
# {Agent Name} 设计稿

## 状态

| 项 | 内容 |
|----|------|
| 任务类型 | 新建 / 重塑 / 局部调整 |
| 目标 profile |  |

## 用户意图

## 使用场景

## 定位

## 能力范围

### 做什么

### 不做什么

## 生态关系

## 权限与工具

## Skill 规划

## 配置与落地

## 表达与人格

## 关键决策

| 决策 | 理由 |
|------|------|

## 未决问题

| 问题 | 影响 |
|------|------|
```

按任务需要裁剪标题。不要为了填满结构而扩写。

## compiled/

`compiled/` 存放从设计稿编译出的运行时草案。

- `SOUL.md`：目标 profile 的身份、定位、能力、边界、工作方式和表达基线。
- `workspace-AGENTS.md`：目标 workspace 的入口说明。只有需要时创建。

编译稿按目标 agent 的真实需要组织标题，不使用固定模板。

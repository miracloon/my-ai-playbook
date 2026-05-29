---
name: ry-plan
description: "【手动触发】Plan 阶段：执行基线制定"
---

# Plan 阶段

## 角色

你是**技术顾问**。在 design 确立的方向上，将意图转化为可执行的任务基线。仍有讨论空间，但偏向指令性。

本 skill 遵循 DEV_WORKFLOW.md 中定义的共享规则。

---

## 入口

1. 读取当前版本的 `design.md`，确认 design 状态为 completed
2. 如果 design 未完成或不存在，提示用户先完成 design 阶段

---

## 编排流程

### 第一步：Brainstorming → 架构确认

调用 superpowers:brainstorming。此时意图已在 design 中明确，brainstorming 会快速通过需求对齐阶段，聚焦架构设计和技术方案。

Brainstorming 产出的架构 spec **不写入文件**，在对话中呈现给用户确认即可。重要的架构决策会自然流入 plan.md 的总览部分。

Brainstorming 完成后，**显式停止**，向用户呈现结果并等待确认。

### 第二步：Writing-plans → Plan

用户确认架构方案后，调用 superpowers:writing-plans 产出执行计划。

### 第三步：Plan 拆分

将 writing-plans 的单文件产出拆分为：

- `plan.md`：总览 + 任务索引 + 关键依赖与完成标准
- `task01.md` ~ `taskNN.md`：每个任务独立文件，含边界、输入输出、依赖与完成标准

拆分完成后向用户呈现 plan 结构，等待确认。

### 第四步：批量执行建议

在 plan 最后附加一个「建议执行分批」段落，基于以下因素给出分批策略：

- **任务连贯性**：有顺序依赖的 task 放同一 batch
- **复杂度预估**：复杂 task 可能消耗大量上下文窗口，应单独成 batch 或建议新会话
- **上下文窗口额度**：连续开发多个 task 后上下文会累积，超过窗口限制会降低质量
- **可并行性**：完全独立、无共享文件的 task 可标注「可并行」，由用户决定是否用 subagent

示例：

```
建议执行分批：
Batch 1（连续执行）: task01-03 — 简单、顺序依赖
Batch 2（可并行）:   task04, task05 — 独立模块
Batch 3（建议新会话）: task06 — 高复杂度，预计消耗大量上下文
```

不要按惯性平均分配，要基于实际任务特征给出建议。

### 第五步（按需）：验收 Task

如果 design.md 定义了验收标准：

- 在 taskNN 序列最后追加一个验收 task
- 内容：编写验收测试代码 + 运行说明 + 结果判读指南
- 该 task 写完代码即完成，不等待运行结果

如果 design.md 未定义验收标准（纯功能性开发），不追加。

---

## 产出

- `docs/dev_notes/<version>/plan.md`
- `docs/dev_notes/<version>/task01.md` ~ `taskNN.md`
- Plan 完成后 git commit（提交 design.md + plan.md + task*.md），此 commit 作为本版本的开发基线
- 等待用户触发 ry-exec

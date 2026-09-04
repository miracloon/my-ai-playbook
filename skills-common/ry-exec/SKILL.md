---
name: ry-exec
description: "【手动触发】Exec 阶段：按计划开发"
metadata:
  version: "1.0.0"
---

# Exec 阶段

## 角色

你是**执行者**。按 plan 基线开发，遇到问题汇报，不自行决定方向变更。

本 skill 遵循 DEV_WORKFLOW.md 中定义的共享规则。

---

## 入口

1. 读取 `plan.md`，确认计划状态
2. 定位当前待执行的 task（读取 task 文档，不凭记忆）
3. 精确圈定本次执行范围

---

## 执行流程

### Batch 级执行

按 plan.md 中的「建议执行分批」组织执行。如果 plan 未提供分批建议，按 task 顺序连续执行。

对当前 batch 中的每个 task：

1. 读取当前 task 文档（task.md 或 taskNN.md）
2. 根据代码类型自行判断测试策略：核心逻辑用严格 TDD，其他代码运行验证即可
3. 调用 superpowers:executing-plans 或 superpowers:subagent-driven-development 执行
4. Task 完成后 git commit
5. batch 内的下一个 task：直接继续（重新读取 task 文档，不凭记忆）

### Batch 边界

当前 batch 所有 task 完成后：

1. 报告 batch 进度
2. 等待用户指令（继续下一个 batch / 停顿 / 进入 summary）
3. 用户确认后才读取下一个 batch 的第一个 task

### Commit 规则

- 每个 task 完成后做一次 commit，提交与任务边界对齐

---

## 硬约束

- 不把 design.md / plan.md / task*.md 当进度看板打勾或补流水账
- 不在任务边界不清时连续推进多个任务
- 不提前产出 summary.md 或 review.md
- 不只凭记忆衔接下一个任务——每次都重新读取 task 文档
- 不在未说明偏移的情况下扩大范围
- 不静默改写 plan.md

---

## 停止条件

出现以下情况时，暂停推进并请求用户裁定：

- 需求发生明显方向变化
- plan.md 的核心边界已不成立
- 多个 task 文档之间出现冲突
- 需要跨越原定范围做新功能
- 发现必须回到 design / plan 重新讨论的重大取舍
- 用户明确要求暂停或改线
- 当前工作实际只是非正式小修，继续沿工作流推进只会增加负担

---

## 产出

- 代码 + 对应的测试（TDD 代码）或运行验证记录（非 TDD 代码）
- Task 级 git commits
- 如遇执行偏移：显式记录偏移内容

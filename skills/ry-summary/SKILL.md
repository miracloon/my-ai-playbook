---
name: ry-summary
description: 【手动触发】Summary 阶段：事实归档快照
---

# Summary 阶段

## 角色

你是**记录者**。归档事实，不做评价。

本 skill 遵循 DEV_WORKFLOW.md 中定义的共享规则。

Summary 是可选的——跳过不破坏系统。design + plan + git log 本身已够恢复上下文。Summary 是锦上添花的快照，不是系统运转的依赖。

Summary 同时作为 ry-docs-control review 流程的参考输入——确保内容结构化、可被后续版本管理流程消费。

---

## 入口

读取当前版本的 `plan.md`、`task*.md`、相关 commit 记录和验证结果。

---

## 产出规则

`summary.md` 是自然语言快照，不需要结构化表格。对照 plan 简洁回答：

- 主要 task 是否完整完成
- 未完成项及其当前状态
- 执行过程中的偏离（与 plan 的差异）
- 验证结果（TDD 测试通过情况、运行验证结果、验收测试结果如有）

### 边界约束

- **不评价**代码质量、不提改进建议——那是 review 的职责
- **不继续开发**——发现遗漏也只记录，不动手修
- **不替代 plan**——不把 summary 写成事后合理化的计划

---

## 产出

- `docs/dev_notes/<version>/summary.md`
- 模板参照：[assets/summary.example.md](assets/summary.example.md)
- 完成后等待用户指令（触发 ry-review 或结束本版本）

---
name: ry-review
description: 【手动触发】Review 阶段：代码与文档质量审阅
---

# Review 阶段

## 角色

你是**独立审阅者**。评估质量，不修代码，不继续开发。

本 skill 遵循 DEV_WORKFLOW.md 中定义的共享规则。

Review 是可选的——跳过不破坏系统。

---

## 入口

读取当前版本的 `design.md`、`plan.md`、`task*.md`、`summary.md`（如有），以及本版本的 git diff 和相关代码。

审阅基于 **git diff（本版本的变更）**，不是全量代码。diff 范围：从本版本第一个 task commit 到最新 commit。如果项目使用 version tag，以 tag 为准。

---

## 审阅维度

- **完成度**：plan 定义的任务是否都已实现
- **一致性**：代码实现是否与 design 意图一致
- **代码质量**：结构是否稳健、安全、易维护、易追溯
- **文档质量**（次要）：开发文档是否清晰、一致
- 可按需调用 superpowers:requesting-code-review，wrapper 可补充项目级视角

---

## 边界约束

- **不重复 summary**——不重新归档事实
- **不顺手修代码**——发现问题只记录，不动手修
- **不自动发起 patch**——修复由用户决定
- **不把 review 写成 summary + 修复的混合体**
- 保持审阅独立性：即使在 exec 的同一会话中进入 review，也不继续开发

---

## 产出

- `docs/dev_notes/<version>/review.md`
- 模板参照：[assets/review.example.md](assets/review.example.md)

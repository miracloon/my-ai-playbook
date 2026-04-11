# DEV_WORKFLOW.md

> Audience: AI
> Status: Normative

本文件是项目开发态下的运行时工作流规范，定义五阶段模型的共享规则。各阶段的具体行为由对应的 skill 定义。

**Wrapper 声明**：本工作流是 superpowers 的上层 wrapper。superpowers 提供基础开发能力（brainstorming、writing-plans、executing-plans 等），本文件在其之上增加阶段管理与运行时约束。冲突时本文件优先——基于 superpowers 自身规则：用户级指令 > superpowers skill。

**前提**：plan 和 exec 阶段依赖 superpowers 已安装。如果检测到未安装，提醒用户安装后再使用对应阶段。design、summary、review 可独立运行。

---

## 1. 五阶段模型

```text
design → plan → exec → summary → review
```

| 阶段 | 回答什么 | AI 角色 |
|------|---------|---------|
| design | 为什么做、边界、关键取舍 | 导师 / 思想伙伴 |
| plan | 执行基线、任务拆分、完成标准 | 技术顾问 |
| exec | 按计划开发、验证、提交 | 执行者 |
| summary | 实际交付了什么、偏移了什么 | 记录者（可选） |
| review | 做得怎么样、哪里有问题 | 审阅者（可选） |

- 阶段由用户通过 skill 命令显式触发，AI 不自动流转到下一阶段。
- summary 和 review 可跳过，跳过不破坏系统。
- 便捷指令「完成 vxx 闭环」：依次执行 summary + review，然后 git commit 本版本所有未提交的文件（包括 summary.md、review.md 及其他漏网文件）。
- 小任务（bug 修复、配置调整、单文件修改等）不需要触发任何阶段 skill，直接处理即可。

---

## 2. Superpowers 覆盖声明

以下使用「替代行为」措辞而非否定措辞。各阶段 skill 可声明额外的阶段特定覆盖。

**产物路径**：所有版本级开发文档写入 `docs/dev_notes/<version>/`，不使用 superpowers 默认的 `docs/superpowers/`。

**阶段流转**：完成当前 skill 后向用户呈现结果并询问下一步，不自动调用下一个 skill。

**Brainstorming 约束**：Design 讨论期间，不调用 superpowers:brainstorming。意图探索由用户主导或通过 ry-design 管理，brainstorming 在 plan 阶段由 ry-plan 显式触发。

**Commit 粒度**：TDD 测试在 step 级别运行，但 git commit 在 task 完成后做一次，保持提交与任务边界对齐。

**Plan 格式**：superpowers writing-plans 产出后，拆分为 `plan.md`（总览 + 任务索引）+ 独立 `taskNN.md` 文件。

---

## 3. 测试策略

### 开发测试：二级分层

| 代码类型 | 测试策略 | 判断依据 |
|---------|---------|----------|
| 核心逻辑 | 严格 TDD（红-绿-重构） | 算法、模型组件、关键数据变换——错了会沉默出错的代码 |
| 其他代码 | 运行验证即可，不写形式化测试 | 可视化、配置、管道搭建、探索性原型——跑一下看就知道对不对的代码 |

- AI 在 exec 阶段根据代码类型自行判断测试策略，不需要在 plan 中显式标注
- 用户如对特定 task 有测试偏好，可在审阅 plan 时指定

### 意图验收

| 验证什么 | 谁执行 | 何时 |
|---------|--------|------|
| 是否达成 design 定义的目标 | 人工 | plan 完成后手动触发 |

- 验收标准在 design.md 中定义（仅当开发测试不足以验证意图时）
- Plan 最后一个 task（按需）：AI 编写验收代码 + 运行说明 + 结果判读指南，写完即完成，不等待运行结果
- 验收测试放 `tests/acceptance/`，注释标注关联的 design 版本

---

## 4. 版本文档体系

```text
docs/dev_notes/<version>/
  design.md · plan.md · task*.md · summary.md · review.md
```

- 版本号由用户手动控制
- 文档目录只放文档，不放代码
- task.md（单一任务）或 task01~NN.md（多任务拆分）按需选择

---

## 5. 跨阶段约束

- 执行中发生偏移，显式记录或回到 plan 层重定，不静默改写 plan.md
- 进入下一个任务前重新读取任务文档，不沿对话惯性继续
- summary 只归档事实不评价；review 只评估质量不修代码；二者不得混合

---

## 6. 项目特定 patch（按需）

本节补充该项目独有的运行时约束（验证路径、commit 规则、命名要求等）。不放通用规则或版本专属细节。

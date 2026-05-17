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
- 便捷指令「完成 vxx 闭环」：触发版本闭环流程（见下方「版本闭环」章节）。
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

## 6. 版本闭环

当用户指示「完成 vxx 闭环」或语义等价的指令时，连续执行以下步骤。

**前置检查**：读取 `plan.md`，对照 git log 确认所有 task 的执行状态。

- 全部完成 → 进入闭环流程
- 存在未完成 task → 报告缺口，由用户裁定（继续闭环 / 先补完 / 标记为放弃）

**Step 1：Summary**

按 ry-summary 协议执行，产出 `summary.md`。
闭环覆盖：不等待用户指令，直接进入 Step 2。

**Step 2：Review**

按 ry-review 协议执行，产出 `review.md`。
闭环覆盖：不等待用户指令，直接进入 Step 3。

**Step 3：控制文档对齐**

评估本版本的开发是否导致项目级控制文档与现实脱节，按需更新。

*是否需要更新的判断*：

基于 summary.md、review.md、本版本 git log（从版本基线 commit 到当前 HEAD），判断是否存在以下信号：

- 新增/删除了模块或功能域
- 技术选型发生变化
- 运转方式/部署方式改变
- 外部依赖增减
- 项目边界或目标调整

以下情况通常**不需要更新**控制文档：

- Bug 修复（除非揭示了文档描述有误导）
- 纯 UI/样式调整
- 内部重构但功能语义和模块边界不变
- 依赖版本升级（除非涉及 API 变化）

判断倾向应**保守**——宁可少更新。遗漏会在后续手动触发 docs-control review 时被捕获。

- 若判断**无需更新** → 报告"本版本未影响控制文档"，跳到 Step 4
- 若判断**需要更新** → 进入以下执行流程

*执行流程*：

1. 基于 summary.md + review.md + git log，形成对本版本变更的结构化理解（对应 docs-control update-protocol 的 Step 1）
2. 加载 docs-control 的 update-protocol，**从 Step 2（影响面扫描）开始执行**，后续完全遵循 update-protocol 的流程和 references
3. 代码库信息按需查阅——仅在文档和 commit 信息不足以判断影响面时，针对性扫描相关模块

*确认机制*：

- 默认（末端确认）：update-protocol 正常的确认流程
- 用户指令含"全自动""无需确认"等语义 → 跳过确认，直接执行更新

**Step 4：Commit**

- Commit A：`docs/dev_notes/<version>/summary.md` + `review.md`（+ 其他未提交的版本文件）
- Commit B（如有控制文档更新）：控制文档变更

> 闭环是便捷的打包操作，不是唯一路径。用户仍可单独触发 ry-summary、ry-review，也可手动触发 docs-control 的 update/review 场景。

---

## 7. 项目特定 patch（按需）

本节补充该项目独有的运行时约束（验证路径、commit 规则、命名要求等）。不放通用规则或版本专属细节。

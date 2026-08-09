---
name: ry-hermes-agent-design
description: Use when designing and initially deploying a new Hermes agent/profile in the current station. Produces reviewable design records, compiled runtime files, and deployment inputs.
metadata:
  ry:
    canonical_source:
      repository: my-ai-playbook
      path: skills/ry-hermes-agent-design
---

# Agent Design

从零设计并首次部署本驻地的新 Hermes agent / profile。不负责既有 agent 的审计、优化、重构或持续迭代。

## 核心概念

| 概念 | 含义 |
|------|------|
| 功能 | 用户视角：agent 能帮用户完成什么任务 |
| 能力 | 技术视角：agent 靠什么手段完成任务（不展开实现细节） |
| 已声明边界 | 用户在意图阶段明确提出的前提或排除项，约束后续设计 |
| 功能边界 | 概念设计形成的职责范围，说明 agent 不承接什么 |
| 设计文件 | 设计过程形成的 `design.md`、`operations.md` 和 `decisions.md` |
| 运行时产物 | 最终编译出的 SOUL.md、AGENTS.md 和按需资产，下游直接使用 |

## 工作契约

- 只处理本驻地新 agent / profile 的设计与首次部署
- 本驻地新 agent 默认以 multiplex secondary profile 形态部署；gateway 由宿主统一托管，本 skill 不涉及 gateway 设计、决策或部署
- 围绕用户想法逐项讨论，不压成一次性问题清单
- 用场景语言和用户讨论，不抛架构术语
- 设计文件保留取舍和依据；运行时产物只保留下游需要的内容
- 前三阶段完成全部设计与配置确认；第四阶段只执行部署

## 任务目录

```text
task/agent-design/{agent_name}/
├── design.md           # 设计记录，也是运行时文档的编译来源
├── operations.md       # 第四阶段直接消费的部署语义
├── decisions.md        # 关键取舍、依据和待补项
└── compiled/
    ├── SOUL.md
    ├── AGENTS.md  # 仅在需要时创建
    └── scripts/   # Cron 等部署脚本，仅在需要时创建
```

## 流程

| 阶段 | 内容 | 推进信号 |
|------|------|----------|
| 1. 意图对齐 | 对齐目标、动机、边界与成功图景 | 设计意图获用户确认 |
| 2. 概念设计 | 建立定位、功能、能力、边界与工作路径 | 概念模型获用户确认 |
| 3. 实现设计与编译 | 设计运行时软配置与平台配置，形成设计记录并编译产物 | 实现方案获用户确认 + 编译质检通过 |
| 4. 部署与验收 | 按既定设计部署、验证并登记新 agent | 启动验收通过 |

### 阶段1：意图对齐

理解用户为什么需要这个 agent，以及最终想获得什么：

- 对齐目标、动机、已声明边界和成功图景
- 区分已经明确的期待与仍待澄清的模糊直觉
- 只处理会改变整体设计方向的歧义

阶段1只确认设计方向，不定义定位、功能、能力或工作路径。关键意图不存在已知分歧并获用户确认后，进入阶段2。

参考：`references/01-intent-alignment.md`

### 阶段2：概念设计

阶段2将已确认的意图转化为完整的 agent 概念模型。以下是需要覆盖的设计语义，不是固定对话轮次；信息充分时合并推进，存在关键分歧时继续讨论。

#### 2.1 建立定位

定义 agent 的角色、用户为什么会找它，以及它在本驻地生态中的位置。

#### 2.2 建立功能模型

从用户视角整理核心功能、功能之间的关系、主干与必要分支，并明确不属于它的需求。只建立足以支撑整体心智模型的骨架，不穷尽功能清单。

当用户主动需要更多建议或启发时，可以在已声明边界内提出合理的功能方向，帮助用户看见尚未想到的用途；建议用于启发，不替用户扩张目标。

#### 2.3 建立能力模型

为每项核心功能建立所需能力，形成“用户目标 → 功能 → 能力”的对应关系。能力保持在概念层，只需说明 agent 依靠什么手段完成功能。

#### 2.4 形成工作路径

将定位、功能和能力组织为接到任务后的主干路径与真实分支，说明用户在什么场景下找它、它如何推进、最终交付什么。不展开运行时 SOP 或具体实现步骤。

#### 2.5 验证概念可行性

通过典型场景推演、思想实验和必要调研，检查功能是否有能力支撑、工作路径是否闭合，以及是否存在必须修改定位或功能模型的硬阻塞。

#### 2.6 呈现概念模型

向用户呈现定位、核心功能、所需能力、主干工作路径、关键分支和功能边界。用户认可概念模型后进入阶段3。

参考：`references/02-concept-design.md`

### 阶段3：实现设计与编译

阶段3将前两阶段的概念设计转化为运行时设计和完整部署输入。

#### 3.1 汇总设计输入

整理前两阶段已经确认的定位、功能、能力、边界、工作路径和生态关系，检查其一致性，不重新讨论概念设计。

#### 3.2 设计运行时上下文

- 设计 `SOUL.md` 所需的身份、职责、判断原则、行为方式和表达基线
- 设计 workspace `AGENTS.md` 所需的工作区结构、用途、治理规则和局部约定
- 按需注入适用的用户通用约束
- 人格设计默认跳过；用户需要或提供人格设计稿时，读取人格参考并纳入设计

设计内容先写入 `design.md`，不是直接把讨论原文当作运行时产物。

参考：`references/03-implementation-design.md`

#### 3.3 确定必要扩展

**Skill：** baseline 默认提供 `hermes-agent` 和 baseline 内置的 `ry-hermes-home-visibility-repair`，不进入设计讨论。除此之外，只选择 Hermes 已有且完成核心功能直接必需的 skill；不设计新 skill、不联网寻找推荐项、不加入仅可能相关的 skill。

**Cron：** 仅当前两阶段已经确认定时、周期或持续触发需求时进入设计，否则跳过。任务必须能在 fresh session 中独立执行，并收敛 timezone、delivery 依赖和无人值守推理路由；设计结果作为部署语义交给阶段4。

不讨论权限和 toolset。

#### 3.4 配置对齐

默认配置直接成立，只讨论偏离默认值或 baseline 无法覆盖的配置。先检查可检索的本机现状；非默认配置和按需部署路由需要额外输入时，在本阶段补齐。

参考：`references/03-implementation-design.md`

#### 3.5 编译与质检

整理设计文件并编译运行时产物：

- `design.md`：设计记录和编译来源
- `operations.md`：阶段4直接消费的部署语义
- `decisions.md`：关键取舍、依据和待补项
- `compiled/SOUL.md`
- `compiled/AGENTS.md`（仅在需要时）
- `compiled/scripts/`（仅在已设计的部署项需要脚本时）

按需加入 Cron 等可部署资产；脚本必须完成静态检查和非破坏性验证。编译质检通过，且阶段4无需再次询问用户，即可进入部署。

`operations.md` 必须形成完整部署契约，明确 profile/workspace、provider/model、skill、环境变量文件、按需路由、外部作用域和登记落点；不适用项明确跳过，不把空白决策留给阶段4。

参考：`references/03-implementation-design.md`

### 阶段4：部署与验收

阶段4只执行阶段3已经确认并写好的部署设计，不在部署过程中继续设计或向用户重复确认。

1. 自检部署输入是否完整；缺失则停止部署并返回阶段3补全
2. 只能从 `github.com/miracloon/hermes-profile-baseline` 安装目标 profile；不得使用任何 profile clone 路径
3. 将编译产物植入目标 profile 和 workspace
4. 应用已确定的配置，执行固定部署 SOP 和已选的可选部署项
5. 验证 profile 结构、配置和启动状态；不执行渠道收发或功能质量测试
6. 登记实际部署结果

部署支持基于已核实现场的中断续跑，但不使用 `--force` 接管碰撞对象，不重复创建 Cron；失败时保留现场和证据，不自动清理。

参考：`references/04-deployment.md`

## Reference 路由

| 需要 | 读取 |
|------|------|
| 阶段1：意图对齐 | `references/01-intent-alignment.md` |
| 阶段2：概念设计 | `references/02-concept-design.md` |
| 阶段3：实现设计与编译 | `references/03-implementation-design.md` |
| 阶段4：部署与验收 | `references/04-deployment.md` |
| 人格设计边界 | `references/personality.md` |
| 用户通用约束（记忆、环境等） | `references/user-constraints/overview.md` |

# Stage 3: Implementation Design & Compilation

阶段3将前两阶段形成的概念模型转化为运行时设计和完整部署输入。

## 汇总设计输入

整理已经确认的定位、功能、能力、边界、工作路径和生态关系，检查其一致性，不重新讨论概念设计。

## 设计运行时上下文

### SOUL.md

设计目标 agent 的身份、职责、判断原则、行为方式和表达基线。

### AGENTS.md

设计 workspace 的用途、结构、治理规则和局部约定。

### 设计输入

- 从 `references/user-constraints/overview.md` 进入，读取适用的子模块；将选中的 `soul/` 模块编译到 `SOUL.md` 的 `## 行为规范`
- 将选中的 `workspace/` 模块整合到 workspace 的 `AGENTS.md`
- 人格设计默认跳过；需要时读取 `references/personality.md`

设计内容先写入 `design.md`，不直接把讨论原文作为运行时产物。

## 确定必要扩展

### Skill

baseline 默认提供：

- `hermes-agent`
- baseline 内置的 `ry-hermes-home-visibility-repair`

默认能力不进入设计讨论，也不由本 skill 单独安装。除此之外，只选择 Hermes 已有且完成核心功能直接必需的 skill；不设计新 skill、不联网寻找推荐项、不加入仅可能相关的 skill。额外 skill 清单写入 `operations.md`。

### Cron

仅当前两阶段已经确认定时、周期或持续触发需求时进入设计，否则跳过。先确认目标 profile 的 timezone；再为每个任务确认 schedule、可在 fresh session 中独立执行的 prompt 或 script、唯一且稳定的 name、delivery、workdir、skill、repeat、是否使用 agent，以及无人值守推理的 provider/model 路由。delivery 依赖渠道或 home target 时一并收敛。设计结果写入部署语义。

本 skill 不设计权限和 toolset。

## 配置对齐

配置对齐用于收敛首次部署所需的配置事实。一轮对话完成，只讨论偏离默认值或 baseline 无法覆盖的配置。可从本机检索的现状先直接检查，包括现有 profile 和路径占用；不把环境事实转化为用户问卷。

profile 名称使用 Hermes 可接受的规范名称。workspace 默认使用 `/home/ry/agent/hermes/workspace/{profile-name}`；只有目标职责明确需要其他现有目录时才偏离。

| 配置项 | 默认值 |
|--------|--------|
| 是否注册别名 | 是 |
| provider | `custom:axonhub-pro` |
| model | `deepseek-v4-flash` |
| 是否接入渠道 | 否 |
| 是否暴露 server API | 否 |

目标功能或部署配置需要环境变量时，由用户提前提供环境变量文件：

- 在 `operations.md` 中记录文件位置及用途
- 阶段4将文件内容按键、无明文暴露地合并到目标 profile 的 `.env`，同名键以用户文件为准
- 用户文件若覆盖 provider sync 受管键，必须在本阶段明确记录为有意覆盖
- 不读取、转述或记录凭据明文

## 文件与编译

| 内容 | 落点 |
|------|------|
| 完整设计与编译来源 | `design.md` |
| 部署配置、额外 skill、Cron 和其他部署语义 | `operations.md` |
| 关键取舍、依据和待补项 | `decisions.md` |
| 身份、职责、边界、判断原则、表达基线 | `compiled/SOUL.md` |
| workspace 用途、结构和局部规则 | `compiled/AGENTS.md`（按需） |
| Cron 等已设计的部署脚本 | `compiled/scripts/`（按需） |

### `operations.md` 部署契约

`operations.md` 不是过程笔记，而是阶段4的完整输入。至少明确：

- profile 名称、是否注册别名、面向生态路由的简短 description
- 由 Hermes 根据 profile 名解析并在部署时核实的 profile home、workspace 的绝对路径、是否新建或复用，以及是否需要 `AGENTS.md`
- provider/model；有 Cron 时同时明确无人值守推理路由
- timezone；没有 Cron 时可沿用环境默认值
- 默认 skill 之外需要启用的 builtin skill
- 环境变量文件的绝对路径、用途及其覆盖优先级
- 需要执行的渠道、API server、Cron 和其他按需路由及全部参数
- 部署脚本的源文件、目标相对路径、执行方式和验证结果
- 会修改目标 profile 之外对象的操作、必要性和明确作用域
- baseline 来源及部署时需要记录的实际 distribution version
- 部署后资产所有权和 baseline 后续升级边界
- 部署状态账本的落点和登记要求
- 部署完成后需要登记到哪个本驻地治理文件

不适用的路由明确标记为不执行，不保留待部署阶段判断的空白项。

### 编译原则

- 从目标 agent 自己的视角写
- 只写目标 agent 运行时需要知道的内容
- 保留必要纠偏，不教 AI 已经具备的通用能力
- 设计过程、历史取舍和被否定方案留在设计文件
- 不为套模板补齐标题；按目标 agent 的真实结构组织
- 用户通用约束是设计输入，按目标 agent 的需要裁剪，不照搬原文

## 质量检验

站在目标 agent 的可见世界里检查：

- 运行时产物是否准确表达已确认设计
- 是否存在下游无法理解的概念或无效约束
- 是否混入设计过程、平台操作、临时判断或通用能力说明
- 结构、标题层级和条件表达是否清楚
- `operations.md` 是否足以让阶段4直接执行
- profile、workspace 和所有按需路由是否都有明确输入
- 环境变量文件是否已经由用户准备且路径可访问
- Cron 是否具备完整任务字段和稳定的无人值守推理路由
- 所需部署路由是否已经具备执行方法

## 完成标准

实现方案获用户确认，编译质检通过，阶段4无需再次询问用户或补做设计。

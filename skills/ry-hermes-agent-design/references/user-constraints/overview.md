# User Constraints

跨 agent 通用的用户约束集。

设计新 agent 时，在运行时上下文设计阶段按需选择适用的约束文件。编译时，将选中的约束整合进目标产物（`SOUL.md` 或 workspace 的 `AGENTS.md`）。

不同 profile 可能需要不同的约束子集——按目标 agent 的职责和场景判断，相关则选用，无关则跳过。

## 行为原则

按目标 agent 的职责选择适用模块，编译进 `SOUL.md` 的 `## 行为规范`，作为运行时行为准则。

| 模块 | 文件 | 作用 |
|------|------|------|
| 语言 | `soul/language.md` | 控制默认回应语言，保留术语表达弹性 |
| 认知漂移与信噪比 | `soul/cognitive-drift.md` | 控制回应方向，避免错误推进或噪声扩散 |
| 记忆与持久化 | `soul/memory.md` | 控制长期状态写入，避免临时理解被固化 |
| 用户级 CLI 的稳定调用 | `soul/user-cli.md` | 发现用户级 CLI 不存在时的行为 |

## 工作区约定

编译进目标 agent workspace 的 `AGENTS.md`，作为工作区使用规则。

| 模块 | 文件 | 作用 |
|------|------|------|
| 工作区结构 | `workspace/workspace-structure.md` | 定义目录用途和访问规则 |
| 开发环境约定 | `workspace/dev-environment.md` | Python、脚本和工程化负担的处理原则 |

## 整合方式

选中的约束文件在编译阶段按目标位置整合：

- `soul/` 下的约束 → 整合进 `SOUL.md` 的 `## 行为规范`
- `workspace/` 下的约束 → 整合进 workspace 的 `AGENTS.md` 对应章节

`overview.md` 是这些子文件的调用入口。设计运行时上下文时先读取本文件，再读取并整合适用的子文件；不能只引用目录或模块名称而遗漏实际内容。

整合时按目标 agent 的实际需要裁剪表达，不照搬原文。约束文件是设计输入，不是模板。

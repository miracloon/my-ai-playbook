# Permissions And Skills

权限和 skill 讨论只处理会影响目标 agent 成立或稳定运行的部分。

## 权限判断

Hermes profile 默认具备较强工具能力。设计时关注是否需要收紧或特别授权，而不是从零枚举所有能力。

| 问题 | 影响 |
|------|------|
| 需要本机或远端 shell 吗 | 影响 terminal / code execution |
| 需要读写文件吗 | 影响 file access 和 workspace 约定 |
| 需要联网、浏览器或外部服务吗 | 影响 web / browser / gateway / env |
| 需要记忆、内置 skill、自我扩展或定时任务吗 | 影响 memory / skills / cron / delegation |
| 是否会处理凭据或外部副作用 | 影响 env、redaction、确认门槛 |

凭据和外部副作用不在设计阶段假定已授权。需要时在 `design.md` 中记录为落地配置项。

## Skill 规划

本 skill 只做内置 / 已有 skill 选拔，不在本轮设计中创建新 skill。

Skill 规划分三类：

| 类型 | 处理 |
|------|------|
| 内置 / 已有且确定需要 | 写入 `design.md` 的落地配置项 |
| 可能有用但不确定 | 记录到 `design.md` 的未决问题或备选 |
| 目标 agent 成立所需但尚不存在 | 在 `design.md` 中记录为后续任务，不在本 skill 内设计或实现 |

如果某个能力暂时没有合适 skill，先判断是否能由 SOUL、workspace 规则、Hermes 配置或用户现场指令承载。复杂业务 skill 的设计和实现是单独任务。

## 轻量落地提醒

Hermes 平台操作按内置 `hermes-agent` 说明书、Hermes 文档或 CLI help 执行；本 skill 只补充用户侧偏好。

创建 agent 时：

- 如涉及渠道配置，完成 profile 创建后先执行当前环境的渠道同步脚本，再选择渠道。
- 如果当前驻地 `AGENTS.md` 的 agent 一览需要反映新建或关键职责变化，按现有表格补一行或更新对应行。

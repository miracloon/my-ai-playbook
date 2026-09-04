# Configuration & Deployment

配置对齐和落地操作参考。

## 配置对齐

配置对齐用于收敛 profile 落地时需要的配置事实。

- 一轮对话完成，不展开成长期讨论
- 只处理落地配置，不重新讨论 agent 画像
- env / credential 不作为默认话题；只有目标功能确实需要时，记录为未决外部依赖

### 默认值

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| gateway 是否常驻 | 是 | 常驻方案默认使用 `systemctl --user` |
| 是否注册别名 | 是 | 按 Hermes 内置说明书 / CLI help 执行 |
| provider / model | 需要用户提供 | 用户未提供时记录为未决，不猜测 |
| 是否同步渠道 | 是 | 设置 provider / model 或选择渠道前，先执行渠道同步 |
| 是否接入 TG 渠道 | 否 | 用户明确需要时再配置 |
| 是否暴露 server API | 否 | 用户明确需要时再配置 |

配置对齐结果写入 `operations.md` 的落地配置项。

### Secret 管理

如果目标 agent 需要 env 变量，创建 `tasks/agent-design/{agent_name}/secret.md`：

- 每行写一个 key 名称
- 用户自行补充对应的 value
- 落地过程中按此文件配置 env，全程不暴露 value

## 部署 SOP

落地时的操作顺序和注意事项：

- 先创建 profile，不使用 clone profile 的方式
- 创建后使用 `~/.local/bin/hermes-provider-custom-sync` 同步 custom provider
- 再设置 provider / model
- 其他配置按 Hermes 内置说明书 / CLI help 执行

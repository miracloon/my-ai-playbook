# Permissions

硬约束的判断逻辑。

软约束（行为原则、表达基线等）通过 SOUL 承载，不在本文件讨论范围。

## 硬约束

通过 Hermes 命令行控制的权限配置：skill 启停、工具启停、文件访问范围等。

## 权限判断

从阻塞推演的结论中提取权限需求。收紧式预备：非必要不开启。

| 问题 | 影响 |
|------|------|
| 需要本机或远端 shell 吗 | 影响 terminal / code execution |
| 需要读写文件吗 | 影响 file access 和 workspace 约定 |
| 需要联网、浏览器或外部服务吗 | 影响 web / browser / gateway / env |
| 需要记忆、内置 skill、定时任务吗 | 影响 memory / skills / cron |
| 是否会处理凭据或外部副作用 | 影响 env、确认门槛 |

## 产出

硬约束写入 `operations.md` 的权限清单，落地时通过 Hermes CLI 配置。

---
name: ry-docker-deploy
description: 【手动触发】在指定设备上部署 Docker 项目（调研、决策、生成配置、SSH 部署、验证）
---

# Docker 项目部署

在用户指定的设备上完成 Docker 项目的完整部署：从项目调研、配置决策，到生成文件、远程部署、验证运行。

## 流程总览

| 步骤 | 节点 | 说明 |
|------|------|------|
| 1 | 设备路由 | 识别目标设备类型，加载对应 reference |
| 2 | 输入判断 | 用户只给项目信息 → 调研+决策；用户给了配置 → 合理化 |
| 3 | 项目调研 + 决策辅助 | 功能画像、分层提问、配置收敛 |
| 4 | 生成配置到本地 | docker-compose.yaml + 按需伴生文件 |
| 5 | 用户确认 | 用户替换占位符、审阅配置、确认推进 |
| 6 | 部署执行 | 端口检查 → SSH 传输 → docker compose up |
| 7 | 部署验证 | 检查容器状态和日志，失败则诊断修复 |
| 8 | 反代提醒 | 仅在项目有特殊反代需求时提醒 |

## Reference 路由

| 需要 | 读取 |
|------|------|
| 1panel VPS 设备信息、基础设施默认值 | `references/vps-h.md` |
| 本地设备部署 | `references/local-device.md`（暂不支持） |
| 纯 VPS 部署 | `references/vps-l.md`（暂不支持） |
| 决策辅助逻辑 | `references/config-decision.md` |
| 反代提醒事项 | `references/reverse-proxy-notes.md` |

---

## 步骤 1：设备路由

用户请求中会指明目标设备。识别设备类型后路由：

| 设备类型 | 路由 |
|----------|------|
| 1panel VPS（oracle-us / sg / de / au） | 加载 `references/vps-h.md`，继续流程 |
| 本地设备 | 告知用户当前暂不支持本地部署 |
| 纯 VPS（无面板） | 告知用户当前暂不支持纯 VPS 部署 |

---

## 步骤 2：输入判断

| 用户输入 | 后续 |
|----------|------|
| 只提供了项目名称、URL 或口头描述 | → 步骤 3（项目调研 + 决策辅助） |
| 同时提供了配置文件内容 | → 面向目标设备合理化配置（应用 `references/vps-h.md` 中的默认值），然后跳到步骤 4 |

---

## 步骤 3：项目调研 + 决策辅助

加载 `references/config-decision.md`，按其中的逻辑执行。

概要：

1. **调研项目**：阅读官方文档、docker-compose 示例、环境变量模板、部署指南
2. **功能画像**：盘点项目支持的功能和组件，不遗漏也不默认裁剪
3. **分层提问**：从使用场景到配置细节逐步收敛用户需求
4. **配置收敛**：所有决策完成后进入配置生成

决策辅助的终止条件是用户的需求和偏好已充分收敛，不设轮次目标。

---

## 步骤 4：生成配置到本地

产出文件到本地路径（具体路径由 hermes 运行时决定）：

| 文件 | 条件 |
|------|------|
| `docker-compose.yaml` | 必须 |
| `.env` | 环境变量较多或多服务共享变量时 |
| 伴生配置文件（json / yaml / toml 等） | 项目需要在启动前准备、且存在必须修改的关键配置时 |

密码、密钥、token 使用占位符 `<CHANGE_ME_xxx>`，由用户在本地手动替换。

---

## 步骤 5：用户确认

展示生成的配置文件。用户：

1. 替换占位符中的敏感信息
2. 审阅整体配置
3. 确认后推进部署；如需修改则回到步骤 4 调整

这是部署前的硬性门槛，不可跳过。

---

## 步骤 6：部署执行

### 6.1 端口占用检查

通过 SSH 检查计划使用的端口：

```bash
ssh {device} "ss -tlnp | grep :{port}"
```

冲突则重新分配。

### 6.2 创建目录 + 传输文件

```bash
ssh {device} "mkdir -p /opt/1panel/docker/compose/{project-name}"
```

将本地配置文件传输到目标设备的项目目录。

### 6.3 启动

```bash
ssh {device} "cd /opt/1panel/docker/compose/{project-name} && docker compose up -d"
```

### 6.4 观察日志

```bash
ssh {device} "cd /opt/1panel/docker/compose/{project-name} && docker compose logs --tail=50"
```

数据库假定用户已通过 1panel UI 创建就绪。如果启动时连不上，提醒用户检查。

---

## 步骤 7：部署验证

```bash
ssh {device} "cd /opt/1panel/docker/compose/{project-name} && docker compose ps"
```

检查所有容器是否处于 running / healthy 状态。查看日志确认无错误。

失败时：诊断原因（日志分析）→ 修复配置或环境 → 重新部署 → 再次验证。循环直到成功或遇到 skill 无法解决的问题。

---

## 步骤 8：反代提醒

加载 `references/reverse-proxy-notes.md` 判断是否需要提醒。

如果项目按 OpenResty 默认配置即可运行，不提醒。仅在有特殊需求时简要提醒，点到为止。

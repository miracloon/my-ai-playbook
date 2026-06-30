# 1panel VPS 设备信息与基础设施默认值

## 设备列表

| 设备名 | SSH 连接 | 架构 | 默认域名模板 |
|--------|----------|------|-------------|
| oracle-us | `ssh oracle-us` | ARM | `{service}.lunary.site` |
| oracle-sg | `ssh oracle-sg` | ARM | `{service}.410710.xyz` |
| oracle-de | `ssh oracle-de` | ARM | `{service}.710410.xyz` |
| oracle-au | `ssh oracle-au` | ARM | 暂无域名 |

## 目录约定

项目部署目录：

```
/opt/1panel/docker/compose/{project-name}/docker-compose.yaml
```

同目录下放置 `.env`（按需）、伴生配置文件（按需）、数据持久化目录。

## 已有基础服务

每台设备已运行以下服务，容器名即服务名，均在 `1panel-network` 中：

- `postgresql`
- `mysql`
- `redis`

已部署 `watchtower`，通过 label 管理自动更新。

### 数据库使用约定

项目需要数据库时，默认使用已有实例。用户通过 1panel UI 创建数据库和用户，不通过命令行。

- 创建与项目同名的专用数据库和专用用户（同名）
- 密码使用占位符 `<CHANGE_ME_db_pass>`
- 连接方式按此模式写入配置，不提问，不额外起数据库容器

Redis 密码使用占位符 `<CHANGE_ME_redis_pass>`，默认 DB 使用 15。

除非项目对数据库版本或配置有特殊要求，不另起容器。

## Compose 默认值

| 配置项 | 默认值 |
|--------|--------|
| 镜像标签 | `latest` |
| 自动更新 | 添加 watchtower label：`com.centurylinklabs.watchtower.enable: "true"` |
| 重启策略 | `unless-stopped` |
| 容器命名 | 始终写 `container_name` |
| Docker 网络 | `1panel-network`（external: true） |
| 端口映射 | `127.0.0.1:{高位端口}:{容器内端口}`，高位端口范围 10000-49998，容器内端口保持项目默认 |
| 卷挂载 | 相对路径 bind mount（如 `./data:/data`），不使用匿名卷 |
| 密码/密钥 | 占位符 `<CHANGE_ME_xxx>` |
| 日志 | 输出到容器 stdout，不挂载日志目录 |

### 环境变量文件策略

- 变量较少时：直接写在 `docker-compose.yaml` 的 `environment:` 中
- 变量较多或多服务共享变量时：使用 `.env` 文件

### 环境变量写入判断

| 层级 | 判断 | 写不写 |
|------|------|--------|
| 启动必需 | 服务起不来或默认值无效 | 必须写 |
| 行为定性 | 安全边界、访问方式、核心行为模式。启动后不易改或改了要重启 | 应该写 |
| 已决策功能 | 功能画像阶段确认要开启的功能所需配置 | 写 |
| 运行微调 | 有合理默认值，或启动后可在 UI/管理面板调整并持久化 | 不写 |

项目有合理默认值的变量，不为了"显得完整"而显式写出。

## 反代相关

每台设备使用 1panel 的 OpenResty 进行反代。反代由用户在 1panel 中手动配置。

当项目配置中涉及反代相关变量时（如 `APP_URL`、`BASE_URL`、`NEXTAUTH_URL`），应填入基于目标设备域名模板的实际域名。

TLS 在反代层终结，compose 内默认关闭应用层 TLS。

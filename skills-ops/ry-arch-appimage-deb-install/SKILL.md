---
name: ry-arch-appimage-deb-install
description: 【手动触发】仅在 Arch Linux 上，将用户提供的 AppImage 或 .deb 安装到 /opt，并创建命令行入口、用户级 desktop 和图标
disable-model-invocation: true
metadata:
  version: "1.0.0"
---

## 意图

将用户提供的 AppImage 或 `.deb` 安装为 Arch 本机应用：

- 本体集中在 `/opt/<name>/`
- shell 中可用 `<name>` 启动，GUI 启动后立即返回
- 应用菜单中有名称、图标和可用入口
- 能识别由本 skill 留下的安装历史，安全更新、补全或注销

用户已经完成安装包选择。直接处理给定文件，不搜索、不比较、不建议改用
pacman、AUR 或其他来源。

## 边界

- 仅限 Arch Linux；执行前调用 `scripts/require-arch.sh`
- 仅处理用户明确提供的 AppImage 或 `.deb`
- 不下载，不使用包管理器，不写系统级 desktop
- 不覆盖其他方案持有的命令、desktop 或 `/opt` 目录
- 注销只移除本 skill 创建的 CLI 和 desktop，保留 `/opt/<name>/`
- 不删除应用本体，不处理应用运行后产生的用户数据

## 交付布局

| 角色 | 路径 |
|------|------|
| 本体 | `/opt/<name>/` 内，格式专用布局见对应 reference |
| 安装记录 | `/opt/<name>/.ry-arch-app-install` |
| CLI | `~/.local/bin/<name>` |
| desktop | `~/.local/share/applications/<name>.desktop` |
| icon | `/opt/<name>/icon.png` |
| 注销 | `/opt/<name>/unregister` |

CLI 与 desktop 是入口；`/opt/<name>/` 是保留的应用资产。

## 入口流程

### 1. 解析与预检

1. 校验 Arch 环境与输入文件。
2. 从安装包内容确定 `name`、显示名、版本、架构和真实 executable；不只依赖文件名。
3. 检查：
   - `/opt/<name>/.ry-arch-app-install` 是否表明已有本 skill 安装历史
   - 旧 `ry-appimage-register` 的 `uninstall` 能确认来源，且仍存在的旧 wrapper、desktop
     也分别通过标记与路径验证时，识别为“旧安装迁移”；确认后先调用
     `migrate-legacy-appimage.sh`
   - `/opt/<name>/` 存在但既没有当前记录、也不能验证为旧安装时，停下说明，不接管
   - `command -v <name>` 指向其他路径时，停下说明，不抢名
   - 同名 desktop 存在但没有 `X-Ry-Arch-App-Install=true` 时，停下说明
4. 判断任务是新安装、更新、同版本刷新或补全。

### 2. 格式路由

- AppImage：完整读取 [references/appimage.md](references/appimage.md)
- `.deb`：完整读取 [references/deb.md](references/deb.md)
- 其他格式：停止；不自行泛化支持范围

格式流程最终应得到：

```text
NAME          规范化命令名
VERSION       安装包版本
SOURCE        /opt 中保留的源文件绝对路径
APP           最终真实 executable 绝对路径
DISPLAY_NAME  应用菜单显示名
WMCLASS       可为空
CATEGORIES    可为空
ICON          /opt/<name>/icon.png
```

### 3. 确认门

每次安装、更新、刷新或补全都先确认。只报告用户需要判断的结果：

```text
将<新安装/更新/刷新/补全> <显示名> <版本>：

- 本体：/opt/<name>/
- 命令：<name>
- 应用菜单：<显示名>

继续？
```

有冲突或格式限制时说明具体问题，不倾倒全部检查过程。

### 4. 公共安装

确认后，机械步骤只调用本 skill 的脚本，均使用绝对路径：

```text
$SCRIPTS/install-unregister.sh <name>
$SCRIPTS/install-cli-wrapper.sh <name> <APP> [固定启动参数...]
$SCRIPTS/write-desktop.sh <name> <ICON> [display_name] [wmclass] [categories]
$SCRIPTS/write-manifest.sh <name> <format> <version> <SOURCE> <APP>
$SCRIPTS/verify.sh <name> <APP> <ICON>
```

desktop 固定调用本 skill 的 CLI；更新 executable 时只需重写 CLI 和安装记录。
`verify.sh` 只验证安装结构，不代表 GUI 已成功显示。首次安装或入口发生变化后，还要实际
启动一次：确认进程没有立即退出，并检查可见窗口或应用日志。无法由当前环境观察窗口时，
明确让用户确认；不要把“结构一致”表述成“应用运行验证通过”。

### 5. 交付

汇总应用名、命令、本体位置和任务类型。不要让用户记管理命令；需要注销时再次调用
本 skill 即可。

## 注销

“注销”固定表示移除集成入口、保留应用资产。

1. 根据 `/opt/<name>/.ry-arch-app-install` 确认这是本 skill 管理的应用。
2. 告知将移除 CLI 和 desktop，保留 `/opt/<name>/`，一句确认即可。
3. 执行 `/opt/<name>/unregister`。
4. 验证本 skill 的 CLI 和 desktop 已消失；若同名系统命令重新暴露，只报告，不删除。

应用 CLI 不拦截 `uninstall` 或 `unregister` 参数，避免占用应用自身命令语义。

## 脚本职责

| 脚本 | 职责 |
|------|------|
| `require-arch.sh` | 拒绝非 Arch 环境 |
| `inspect-deb.sh` | 只读检查 `.deb` 元数据、路径与安装脚本 |
| `extract-deb.sh` | 将 `.deb` 数据和控制区提取到私有版本目录，不执行安装脚本 |
| `extract-icon.sh` | 从 AppImage 提取 icon 和 desktop 元数据 |
| `migrate-legacy-appimage.sh` | 验证并移除旧 skill 的入口和旧注销脚本，为新记录让路 |
| `install-cli-wrapper.sh` | 写入通用 detach CLI |
| `write-desktop.sh` | 写入带所有权标记的用户级 desktop |
| `write-manifest.sh` | 写入安装历史与当前入口 |
| `install-unregister.sh` | 写入只移除受管入口的注销脚本 |
| `verify.sh` | 验证 executable、CLI、desktop、icon、manifest 与注销入口的结构一致性 |

CLI 前台调试：`RY_ARCH_APP_FOREGROUND=1 <name>`。`-h`、`--version`、`-w`
等需要终端结果的参数自动以前台方式运行。

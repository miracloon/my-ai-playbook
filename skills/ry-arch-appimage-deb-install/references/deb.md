# .deb 安装

## 模型

`.deb` 是文件树和安装元数据，不是单个可执行文件。本 skill 不模拟 Debian 系统安装；
它把包内容导入 `/opt/<name>/` 的私有版本目录，再创建用户级入口。

```text
/opt/<name>/
├── packages/<原文件名>.deb
├── versions/<version>/root/       # 包内 data 文件树
├── versions/<version>/control/    # control 与 maintainer scripts，仅供检查
├── current -> versions/<version>
├── icon.png
├── .ry-arch-app-install
└── unregister
```

不把包内路径直接写入真实 `/usr`、`/etc` 或 `/var`，不执行 maintainer scripts。

## 只读检查

移动源文件和确认执行前，先调用：

```text
$SCRIPTS/inspect-deb.sh <deb绝对路径>
```

结合输出和包内 desktop 判断：

- `Package`、`Version`、`Architecture`
- 包内 desktop、图标和候选启动入口
- 是否带 `preinst`、`postinst`、`prerm`、`postrm`
- 是否包含 systemd、udev、DBus policy、`/etc`、`/var` 等系统集成文件
- 主程序是否能够从私有目录运行

`Architecture` 必须与本机兼容。版本从 control 读取，使用 Arch 的 `vercmp` 比较，不从文件名猜。

## 支持边界

适合导入：

- 桌面应用主体位于包内单一 `/opt/<vendor>/` 或其他可私有化目录
- `/usr/bin` 只是 symlink 或轻量 launcher
- `/usr/share` 主要包含 desktop、icon、mime 或文档
- 找到的真实 executable 能直接从私有 root 运行

停止安装：

- 依赖必须执行的 maintainer script
- 需要写入真实 `/etc`、`/var`、systemd、udev、DBus policy 或创建系统用户
- 需要 root-owned setuid 文件
- 主程序依赖无法安全改写的绝对系统路径
- 必需动态库缺失，且用户尚未确认如何处理
- 无法确定唯一真实 executable

不要因为失败而退回到 `dpkg`、通用转换器或向系统目录直接解包。

## 提取与整理

确认后：

1. 创建：

```text
/opt/<name>/packages/
/opt/<name>/versions/
```

2. 将原 `.deb` 默认 `mv` 到 `/opt/<name>/packages/<原文件名>.deb`。
3. 以 control 中的版本生成安全的版本目录名，然后调用：

```text
$SCRIPTS/extract-deb.sh <保留的deb绝对路径> /opt/<name>/versions/<version>
```

同版本刷新时，先提取到新的 staging 目录并验证，再替换旧版本目录；不要在验证前破坏现有版本。

4. 根据包内 desktop 的 `Exec=` 找入口：
   - `/usr/bin/<name>` 映射到私有 `root/usr/bin/<name>`
   - 若它是指向 `/opt/...` 的绝对 symlink，将目标映射为私有 `root/opt/...`
   - 若 launcher 只负责转调包内真实程序，CLI 直接指向真实程序
   - 不执行或保留会写系统路径的安装 launcher
5. 检查 executable：
   - 有执行权限
   - ELF 文件用 `ldd` 检查 `not found`
   - 不依赖私有 root 之外尚不存在的绝对路径
6. 从 `root/usr/share/icons`、`root/usr/share/pixmaps` 或应用目录选取匹配图标，
   优先最大的 PNG，复制为 `/opt/<name>/icon.png`。
7. 将 `current` 原子切换到已验证的版本目录。

最终交回公共流程：

```text
FORMAT=deb
VERSION=<control Version>
SOURCE=/opt/<name>/packages/<原文件名>.deb
APP=/opt/<name>/current/root/<真实程序路径>
ICON=/opt/<name>/icon.png
```

desktop 的显示名、`StartupWMClass`、`Categories` 优先沿用包内 desktop。

## 更新与注销

- 新版本保留旧版本目录，验证成功后切换 `current`
- 同版本刷新替换该版本内容，但保留原 `.deb` 安装包
- 更旧版本默认拒绝，用户明确允许时可切换
- 注销只删除公共 CLI 和用户级 desktop
- `.deb`、提取后的版本、icon、manifest 和用户配置均保留，可重新注册

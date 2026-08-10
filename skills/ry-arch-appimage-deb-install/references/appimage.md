# AppImage 安装

## 模型

AppImage 本身是应用资产。源文件移入 `/opt/<name>/`，CLI、desktop 和 icon 是可重建入口。

```text
/opt/<name>/<原文件名>.AppImage
/opt/<name>/icon.png
/opt/<name>/.ry-arch-app-install
/opt/<name>/unregister
```

同一目录可保留多个版本；当前入口始终指向 newest。

## 命名与元数据

- `name`：文件名小写，去版本、架构和扩展名
- 显示名：优先使用 AppImage 内 desktop 的 `Name=`
- icon、`StartupWMClass`、`Categories`：由 `extract-icon.sh` 提取

例：

```text
Cursor-3.12.17-x86_64.AppImage → cursor
```

## 版本

newest = 扫描 `/opt/<name>/*.AppImage` 后按版本判断，不按修改时间猜测。

| 情况 | 动作 |
|------|------|
| 新版本 | 移入并接管当前入口 |
| 同版本 | 刷新 CLI、desktop、manifest 和注销入口 |
| 更旧 | 拒绝，除非用户明确允许降级 |
| 无法提取版本且只有一份 | 使用该文件 |
| 无法提取版本且存在多份 | 停下列出候选，不猜 |

## 执行

1. 若预检认出旧 `ry-appimage-register` 安装，确认后先调用：

```text
$SCRIPTS/migrate-legacy-appimage.sh <name>
```

该脚本只有在旧 wrapper、desktop 和旧注销脚本都通过所有权特征检查后才会移除它们；
AppImage 和 icon 不受影响。

2. 创建 `/opt/<name>/`。
3. 源文件不在目标目录时默认 `mv`，然后 `chmod +x`。
4. 重新计算 newest，得到 `APP`。
5. icon 不存在时调用：

```text
$SCRIPTS/extract-icon.sh <APP> /opt/<name>/icon.png
```

`FORCE=1` 可强制重抽。提取失败时停下；需要通过网络寻找图标必须先征得用户同意。

6. 将提取结果交回主 `SKILL.md` 的公共安装流程：

```text
FORMAT=appimage
SOURCE=<APP>
APP=<newest AppImage>
ICON=/opt/<name>/icon.png
```

不创建指向 AppImage 的 symlink；CLI 必须使用公共 detach wrapper。

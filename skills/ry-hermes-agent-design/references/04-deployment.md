# Stage 4: Deployment & Verification

阶段4只消费阶段3已经确认并写好的部署输入。部署过程中不补做设计、不重新确认配置，也不临场推导缺失值。

## 固定 SOP

### 1. 自检

按 `operations.md` 部署契约检查设计记录、编译产物、路径、配置事实和所需操作路由是否完整，并确认环境变量文件存在。环境变量内容不载入模型上下文、不输出；后续仅由受控程序解析并合并。缺失时停止部署，返回阶段3补全。

检查 profile 名、别名和 workspace 路径是否已存在。profile 已存在时先检查 `local/deployment-state.yaml`：部署身份和编译输入摘要一致且状态未完成，才按账本续跑；否则按碰撞停止。未在 `operations.md` 声明复用的 workspace 发生碰撞时同样停止。不使用 `--force`，也不接管既有对象。明确复用既有 workspace 时，只植入已声明的文件，不改动无关内容。

### 2. 安装 baseline

解析并记录 baseline 仓库当前要部署的不可变 Git ref，再使用 profile distribution 安装新 profile：

```bash
hermes profile install 'github.com/miracloon/hermes-profile-baseline#<ref>' \
  --name <profile-name> --yes
```

阶段3确认注册别名时追加 `--alias`。这是新 profile 的唯一创建路径。不得使用 `hermes profile create --clone`、`--clone-all` 或 `--clone-from`。baseline 是毛坯部署基座，不是既有 profile 的复制品。

安装后立即用 `hermes profile info <profile-name>` 核实 distribution source/version，并写入部署结果；实际来源不匹配时停止。

随后在 `<profile-home>/local/deployment-state.yaml` 建立部署状态账本，以原子写入方式记录 deployment id、baseline source/ref/version、编译输入摘要、步骤状态、已创建的非幂等对象和最后错误。只有现场与账本中的部署身份和输入摘要一致时才允许从中断点续跑；否则按碰撞处理。不重新安装 baseline，不重复创建 Cron。

baseline 在本流程中只作为首次部署基座。植入编译产物后，不直接对成品 profile 执行 `hermes profile update`：该命令会替换 `SOUL.md`、`skills/`、`cron/` 等 distribution-owned 路径，覆盖本 agent 的装修结果。

### 3. 植入运行时产物

- 将 `compiled/SOUL.md` 写入目标 profile
- 创建目标 workspace，并按需将 `compiled/AGENTS.md` 写入 workspace
- 若存在 `compiled/scripts/`，将其中脚本按相对路径植入目标 profile 的 `scripts/`，保留所需执行权限
- 写入 profile description，作为生态路由信号：

  ```bash
  hermes profile describe <profile-name> --text '<description>'
  ```

- 将 profile 的工作目录指向目标 workspace：

  ```bash
  hermes -p <profile-name> config set terminal.cwd '<absolute-workspace-path>'
  ```

### 4. 配置初始化

按以下顺序执行：

1. 检查并执行本机受管 provider 同步脚本：

   ```bash
   ~/.local/bin/hermes-provider-custom-sync check
   ~/.local/bin/hermes-provider-custom-sync apply
   ```

   这是本机受管 provider 的全局批量同步，会处理未被脚本配置排除的所有 profile；该作用域是预期行为，不把它误解为目标 profile 专用命令。执行后确认目标 profile 已具有受管 `custom_providers` 和所需环境变量键，只检查结构、键名和数量，不输出凭据值。
2. 若 `operations.md` 声明了环境变量文件，将其按键合并到目标 profile 的 `.env`：

   - 不读取、展示、转述或记录变量值
   - 保留 provider sync 已写入且用户文件未声明的变量
   - 同名变量以用户文件为准
   - 覆盖 provider sync 受管键时，必须与 `operations.md` 中声明的有意覆盖一致
   - 不直接覆盖整个目标 `.env`
   - 使用当前环境中的结构化 dotenv parser 在受控进程内完成原子合并；stdout 只返回状态或键数，不临时固化一套新的 dotenv 解析规则
   - 合并完成后确保目标 `.env` 仅当前用户可读写，并只验证键名、数量和权限
3. 迁移新 profile 配置到当前 Hermes schema：

   ```bash
   hermes -p <profile-name> config migrate
   ```

   这里是配置 schema 迁移，不是 profile 创建，也不触发 clone
4. 应用阶段3确认的 provider/model：

   ```bash
   hermes -p <profile-name> config set model.provider 'custom:axonhub-pro'
   hermes -p <profile-name> config set model.default 'deepseek-v4-flash'
   ```

   非默认值将命令中的值替换为阶段3确认值；需要 Hermes 交互式发现或选择时才使用 `hermes -p <profile-name> model`。完成后执行 `config check`。
5. 应用阶段3确认的 memory provider。继承本驻地当前已激活的 Honcho 时，先执行幂等的 profile 同步，为新 profile 创建独立 AI peer并共享既有用户 workspace；再为目标 profile 启用 Honcho：

   ```bash
   hermes honcho sync
   hermes -p <profile-name> config set memory.provider honcho
   hermes -p <profile-name> memory status
   ```

   不通过 clone 初始化 Honcho。需要查看全局 peer 映射时使用 `hermes honcho peers`。若本驻地当前未激活 Honcho，而阶段3明确为目标新引入 Honcho，则按 `hermes -p <profile-name> memory setup honcho` 的 provider 初始化流程执行，不能直接调用尚未注册的 `hermes honcho` 子命令。其他 memory provider 按其 profile 隔离机制处理；只有存在额外初始化要求时才执行对应操作。阶段3选择 built-in only 时不启用外部 provider。
6. 按下方路由应用 skill keep-list、Cron、渠道、API server 和其他配置

所有固定配置和按需路由完成后，执行最后的"重启宿主 gateway"步骤。

## 按需操作路由

以下路由只在 `operations.md` 声明对应需求时执行。路由中的值均来自阶段3，不在阶段4推导。

### 额外 Skill

使用当前 Hermes 的原生 skill 管理能力，使目标 profile 最终只启用：

- baseline 提供的两个默认 skill
- `operations.md` 声明的额外 builtin skill

额外 skill 不从网络或公共 registry 安装，也不使用 `skills opt-in --sync` 恢复整个 catalog。通过当前 Hermes 的 `hermes_constants.get_bundled_skills_dir` 路径解析入口定位本机内置目录，只把阶段3声明的完整 skill 目录复制到目标 profile，保留其相对目录结构和文件权限。不得复制或覆盖 baseline 已提供的同名默认 skill。复制后它在目标 profile 中显示为 profile-owned `local` skill，这是预期状态。

需要调整启用状态时使用 `hermes -p <profile-name> skills config`。完成状态同时满足：`.no-bundled-skills` marker 仍存在，目标 skill 文件完整，且 `hermes -p <profile-name> skills list --enabled-only` 只显示预期集合；不以某条命令执行成功为准。

### Cron

按 `operations.md` 中已经设计好的任务语义创建任务：

创建前先执行 `cron list --all`，按任务 name 和语义检查是否已经存在。已存在同一任务时验证或更新，不重复创建；同名但语义不同则停止并返回阶段3处理命名冲突。

```bash
hermes -p <profile-name> cron create '<schedule>' '<prompt>' \
  --name '<name>'
```

按设计追加 `--deliver`、`--workdir`、`--repeat` 和 `--skill`；无 agent 的脚本任务使用 `--script <path> --no-agent`。prompt 必须是自包含任务指令，不引用设计对话或部署会话中的临时上下文。delivery 指向渠道时，先确认对应渠道和 home/specific target 已配置。创建后用以下命令确认：

有 agent 的 Cron 必须应用阶段3确定的无人值守推理路由。优先使用当前 Hermes CLI 已公开的 per-job provider/model pin；若当前版本未公开对应参数，则先核实当前运行时实际支持的 profile 级 Cron provider/model 配置键，再设置 Cron 默认路由。不要照抄其他版本的字段，不依赖未来可能变化的交互式主模型，也不通过关闭 drift guard 绕过漂移保护。

创建 Cron 前应用阶段3确认的 timezone，并通过 `config get timezone` 验证；不根据执行机器的当前时区静默推断用户意图。

```bash
hermes -p <profile-name> config set timezone '<timezone>'
hermes -p <profile-name> config get timezone
```

```bash
hermes -p <profile-name> cron list
```

### Telegram

阶段3已声明 Telegram 且环境变量文件已准备时，不重新进入交互式配置，只确认环境变量已写入目标 profile：

```bash
hermes -p <profile-name> config check
```

至少需要 `TELEGRAM_BOT_TOKEN`，并具备阶段3确认的访问控制；默认不开放给未授权用户。Cron 或主动投递依赖 home channel 时，还需具备 `TELEGRAM_HOME_CHANNEL` 或明确的 specific target。多 profile 场景不得复用同一个 Telegram bot token。

### Server API

阶段3已声明 API server 且环境变量文件已准备时：目标 profile 不设置 `API_SERVER_ENABLED`、`API_SERVER_KEY` 或独立监听端口；API server listener、鉴权与端口绑定配置只存在于 default profile。若需要为此修改 default profile，其配置项和重启操作必须已在 `operations.md` 中单独声明；不得在阶段4临场扩大作用域。

```bash
hermes -p <profile-name> config check
```

## 启动验收

确认：

- profile 由 baseline distribution 创建，未走 clone
- baseline 仅作为 bootstrap source，成品资产所有权和后续升级边界已记录
- 别名状态与阶段3设计一致
- 编译产物位于正确位置
- workspace 和工作目录正确
- 环境变量文件已按设计应用，且未在对话中暴露明文
- provider sync 已执行
- memory provider 已完成目标 profile 所需的初始化
- skill 启用集合符合阶段3设计
- 配置可被当前 Hermes 正常加载
- profile 能够正常启动并完成一次最小响应

关键验证入口：

```bash
hermes profile info <profile-name>
hermes -p <profile-name> config check
hermes -p <profile-name> doctor
hermes -p <profile-name> chat -q '<minimal-prompt>' -Q
```

有 Cron 时检查 `cron list` 与 `cron status`。有 API server 时验证 health endpoint；不在验收命令中暴露 API key。宿主 gateway 对目标 profile 的加载状态在最后一步重启后由用户或后续会话确认。

不测试渠道实际收发、业务功能质量或人格体验；这些由用户后续验用。

## 登记结果

记录实际部署状态、部署偏差和待用户验用事项。将 profile 名、类型、职责、默认 workspace、可委派状态和必要备注登记到阶段3指定的本驻地 agent 一览；只登记本驻地 agent，不扩写其他物理驻地的信息。登记中明确"宿主 gateway 重启后加载状态"为待确认项。

验收通过并记录 baseline source/version 后，将目标 profile 根目录的 `distribution.yaml` 移入用户自有路径 `local/bootstrap-distribution.yaml`。成品 profile 因此解除 baseline distribution 关联，避免 `profile update` 覆盖装修资产；来源记录仍保留。后续 baseline 变化若需应用，作为显式迁移审查差异并重放该 agent 的部署契约。

```bash
mkdir -p '<profile-home>/local'
mv '<profile-home>/distribution.yaml' \
  '<profile-home>/local/bootstrap-distribution.yaml'
hermes profile show <profile-name>
```

验证 `profile show` 不再显示 Distribution，同时 bootstrap manifest 仍存在于 `local/`。

每个步骤完成后原子更新部署状态账本。部署中途失败时记录最后一个成功步骤和失败证据，保留现场供续跑；不自动删除 profile、workspace 或已创建的运行状态。完成登记与 distribution 解除关联后，将账本标记为 completed，作为后续审计和显式迁移的依据。

## 重启宿主 gateway

所有固定配置和按需路由完成后，执行最后一步：重启宿主 default gateway，使其加载目标 profile。

```bash
systemctl --user restart hermes-gateway
```

执行本步骤会中断当前会话。这是预期且允许的：所有部署操作已在重启前完成，重启后加载状态已作为待确认项登记，不依赖本会话继续输出。

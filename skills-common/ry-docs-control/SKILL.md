---
name: ry-docs-control
description: "【手动触发】项目控制面文档的初始化、更新与对齐"
metadata:
  version: "1.1.0"
  ry_agent_update: source
  ry_source_path: skills-common/ry-docs-control
---

# 控制面文档 Skill

## Skill 定位

本 skill 负责项目控制面文档（AGENTS / INTENT / WORKFLOW / SPEC / CLAUDE）的全生命周期管理。
**进入本 skill 后，不要进入开发、调试、架构设计或任何非文档构建的工作模式。**

---

## 场景路由

进入本 skill 后，根据用户指令的语义确认场景，加载对应协议执行。
确认后向用户简述即将进入的场景；若语义模糊，直接询问用户。

| 场景 | 触发条件 | 典型触发语义 | 加载协议 |
|------|---------|-----------|---------| 
| **初始化** | 项目无控制文档，或控制面需重建 | "初始化控制文档"、"建立文档体系"、"从零开始" | → [protocols/init-protocol.md](protocols/init-protocol.md) |
| **事实更新** | 用户提出特定变更需反映到文档（指令包含明确的领域/功能描述） | "我改了 X"、"新增了模块"、"选型换了" | → [protocols/update-protocol.md](protocols/update-protocol.md) |
| **审阅与对齐** | 文档可能与代码现实脱节（指令无明确领域目标，侧重全面对齐） | "检查文档"、"对齐"、"审阅控制面" | → [protocols/review-protocol.md](protocols/review-protocol.md) |

---

## 资源目录

### 用户配置

| 资源 | 内容 |
|------|------|
| [AI_GLOBAL_PREFS.md](AI_GLOBAL_PREFS.md) | 跨项目全局偏好（种子数据，仅初始化场景读取，落文时写入项目控制文档） |

### 共享查询手册

以下资源供各协议文档按需引用。**具体加载时机由各协议文档指定。**

| 资源 | 内容 |
|------|------|
| [matrix-boundaries.md](references/matrix-boundaries.md) | 文档矩阵定义、职责边界、归属速查 |
| [question-strategy.md](references/question-strategy.md) | 提问规则、高风险探查维度清单、充分性判断 |
| [output-contract.md](references/output-contract.md) | 正文准入标准、成文约束、长度密度参考 |
| [structure-contract.md](references/structure-contract.md) | 文档结构治理、栏目索引表、`##` 锁定规则 |
| [anti-drift-rules.md](references/anti-drift-rules.md) | 信息来源优先级、禁止行为清单 |
| [assets/](assets/) | 各控制文档的结构模板与写作指南 |

---

## 与阶段性开发协同

阶段性开发材料可以帮助理解变化，但不自动取得项目长期事实权：

- Design 表达开发意图、已确认决定和开放问题，不证明实现已经落地；
- Plan 表达暂时执行路径，不表示当前进度；
- State 表达当前工作状态，已验证结论仍需结合相应证据；
- Reconcile 形成的长期治理候选是经过阶段收束的优先输入，但仍需与代码、运行现实和当前控制文档核验。

只有已经确认、实际落地、证据充分且会持续影响未来判断的内容才进入长期治理。临时探索、执行历史、未完成实现和开放问题继续保留其阶段身份，不编译成项目当前事实。

---

## 全局约束

无论哪个场景，以下约束始终生效：

1. **关键治理裁决归用户**——AI 主动调查、组织和提出判断；用户当前指令已经授权生成或更新时，不重复请求同一确认
2. **事实身份不能互换**——代码和运行现实是实现证据，不自动证明其应成为长期规范；用户意图和阶段决定也不自动证明已经落地
3. **模板不是填写清单**——`assets/` 中的模板提供结构底盘，不是每个栏目都要写满
4. **本 skill 只管控制面**——阶段性开发文档和运行命令不在范围内
5. **阶段材料不是事实结论**——按其信息身份使用，并以项目现实核验长期治理候选

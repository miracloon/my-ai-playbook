---
name: style-guide
description: 与 skill-creator 默认行为不同的风格覆盖项
---

# 风格覆盖项

以下仅记录本体系与 skill-creator 默认行为不同的偏好。skill-creator 已经教过的通用规范不在此重复。

## SKILL.md 篇幅

skill-creator 允许 SKILL.md 到 500 行。本体系偏好更精简：大多数 skill 在 50-100 行可覆盖核心内容，超出时优先将细节下沉到 references。

篇幅服务于清晰度，不是硬上限。流程型 skill 如果拆分反而增加认知负担，可以保持单文件，只要保持可快速扫描。

## 表达风格

- 陈述事实和偏好，不用说教口吻（"你应该"、"请注意"、"建议"）
- 解释 why，不堆砌 MUST/ALWAYS
- 具体示例优先：代码、命令、配置、输出格式等用代码块；概念判断、设计理由、边界说明用短 prose 或表格

## 主题分区表格

若 skill 有多个 references 或多主题域，使用三列表格索引：

```markdown
| Topic | Description | Reference |
|-------|-------------|-----------|
| CLI Commands | Install, add, remove | [core-cli](references/core-cli.md) |
```

单文件闭合型 skill 不需要表格。

## References

按任务或主题独立组织，阅读时不依赖 sibling reference。篇幅以可扫描为准，推荐 100-300 行，按任务边界拆分而非按行数。

## Description 写法

- 写给下游宿主——用于 AI 匹配触发，不是给作者的注释
- 自动触发：`[做什么]。Use when [什么场景]`
- 手动触发：`【手动触发】[具体动作描述]`，措辞特异、动作化，避免泛化策略表述
- 若存在高相似误触发场景，用短语标出排除边界；手动触发 skill 通常不需要强行列出 non-goals

## 手动触发规范

是否手动触发由用户决定。确认为手动触发后：

**双重标记：**
1. Frontmatter: `disable-model-invocation: true`（平台层面阻止）
2. Description 开头: `【手动触发】`（语义层面阻止，平台无关）

**Description 污染防控：**
AI 加载 skill 列表时会读到所有 description，即使不触发也受其影响。手动触发 skill 的 description 必须描述动作而非陈述策略，保持特异性，在未被调用时对 AI 行为产生最小影响。

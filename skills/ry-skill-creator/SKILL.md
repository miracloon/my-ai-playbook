---
name: ry-skill-creator
description: 【手动触发】创建新的 skill，在 skill-creator 基础上叠加增强对齐、风格约束和格式自检
disable-model-invocation: true
---

在 skill-creator 的基础上，叠加增强对齐和风格约束，创建符合本体系规范的 skill。

**Important:** 内容风格与格式规范以本 skill 为准。工程流程（测试、评估、打包）以 skill-creator 为准。当二者冲突时，遵循此优先级。若目标平台有明确的 frontmatter 或校验要求，平台契约优先于风格偏好。

## 流程

### 阶段 1：设计对齐

使用 ry-grill 对 skill 的设计方案进行端到端实例模拟和决策点排查。

**起始锚点：** 先描述一个具体的端到端用例——用户说什么 → AI 做什么 → 产出什么。从这个用例出发展开设计决策。

聚焦方向（供 ry-grill 参考）：

- 触发方式：手动还是自动？
- 行为设计：被调用后做什么、怎么做？
- scope 边界：什么属于、什么不属于？
- 退出条件：什么时候算完成？

ry-grill 完成后输出决策摘要，摘要应尽量覆盖：触发方式、正向用例、反向用例 / non-goals（相似但不适用的场景；如影响触发判断，应体现在 description 中）、scope 边界、退出条件、资源需求（references / scripts / assets）、未决问题。

### 阶段 2：委托 skill-creator

ry-grill 已完成设计方案的对齐。设计决策已在对话上下文中确认。

进入 skill-creator 流程，从 Interview and Research 开始——补全实现层的技术细节（edge cases、依赖、格式、信息源研究）后进入写作。对于 ry-grill 阶段已确认且未被新信息挑战的设计决策，不重复提问。

skill-creator 的工程流程（Interview and Research、drafting、testing、eval、iteration、打包）自治运行，本 skill 不干涉。

### 阶段 3：格式自检

skill-creator 每次产出或修改 SKILL.md 后，在交付用户之前，用 [style-guide](references/style-guide.md) 和 [checklist](references/checklist.md) 逐项验收。不符合项先修正再交付。

## 风格覆盖速览

详见 [style-guide](references/style-guide.md)。仅记录与 skill-creator 默认行为不同的偏好：

| 覆盖项 | 本体系偏好 |
|--------|-----------|
| SKILL.md 篇幅 | 50-100 行，超出优先下沉 references（skill-creator 允许 500 行）|
| 表达 | 陈述事实，解释 why，不堆砌 MUST/ALWAYS |
| 示例 | 具体示例优先，不限于代码块 |
| 手动触发 | 双重标记 + description 污染防控 |
| Description | 自动：`[做什么]。Use when [场景]`；手动：`【手动触发】[具体动作]` |

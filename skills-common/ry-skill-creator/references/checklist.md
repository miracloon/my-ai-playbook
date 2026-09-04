---
name: checklist
description: Skill 创建完成后的验收清单
---

# 自检清单

skill-creator 每次产出或修改 SKILL.md 后，逐项对照。不符合项修正后再交付用户。

## 风格覆盖

- [ ] SKILL.md 是否保持精简、可快速扫描？超出 100 行时是否考虑过下沉到 references？
- [ ] 表达是否简洁？有无说教口吻或不必要的 MUST/ALWAYS？
- [ ] 若存在多个 references，是否使用三列表格索引？单文件闭合型 skill 不适用
- [ ] description 是否符合格式？（自动触发: `[做什么]。Use when [场景]`；手动触发: `【手动触发】[具体动作]`）
- [ ] 如为手动触发：是否设置了双重标记？description 是否避免了泛化策略性表述？

## 设计完整性

- [ ] description 是否在语义上能被目标使用场景自然匹配？（不要穷举触发短语）
- [ ] 执行流程是否有明确的退出条件？
- [ ] 是否明确了不适用场景 / non-goals？若用于防误触发，是否已在 description 中轻量体现？

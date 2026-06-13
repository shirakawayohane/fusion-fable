---
description: Fusion chain with GPT-5.5 as the checker (opus4.8-gpt5.5)
argument-hint: <your question>
---
Invoke the **fusion** skill on the task below, forcing the `opus4.8-gpt5.5` chain:
Opus 4.8 drafts a complete answer → GPT-5.5 (via `codex exec`) independently checks it →
Opus fuses draft + critique into the final answer.

Follow the skill's SKILL.md exactly (generate → check → fuse) and present the standard sections
(Confirmed / Corrections / Contradictions / Gaps filled / Blind spots / Final answer). Use a SINGLE
Opus 4.8 generator and GPT-5.5 as the only checker — do not add a second Opus checker. If the `codex`
CLI is not installed, stop and say so rather than silently downgrading to the opus4.8-4.8 chain.

Task: $ARGUMENTS

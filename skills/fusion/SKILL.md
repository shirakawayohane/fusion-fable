---
name: fusion
description: >-
  Answer a hard question with a two-stage Fusion chain: Opus 4.8 drafts a complete answer, then a
  SECOND model independently checks and fuses on top of it — verifying claims, correcting errors,
  filling gaps, and surfacing blind spots — before Opus merges everything into one higher-confidence
  final answer. The second checker is another Opus 4.8 (slug opus4.8-4.8) or GPT-5.5 via codex (slug
  opus4.8-gpt5.5) when its CLI is installed, optionally chained with Gemini 3.1 Pro
  (opus4.8-gpt5.5-gemini3.1pro). Opus always drafts and owns the final fuse — the chain can't be
  reversed. Use this whenever the user asks to "run it through Fusion", wants a second model to
  check/verify/fuse an answer, wants a cross-checked or higher-confidence answer, or wants another
  model's eyes on a hard question — even if they don't say "fusion". Best for high-stakes research,
  design calls, and debugging where being confidently wrong is expensive.
---

# Fusion

Fusion is a two-stage chain. **One Opus 4.8 drafts an answer; a second model then checks it** —
independently re-verifying with its own web search and bash, correcting what's wrong, filling what's
missing, naming what both missed — and then Opus fuses the draft and the critique into one final answer
that has survived an outside model's scrutiny.

This is not a parallel panel of peers. It's draft → check → fuse. The value is that the second model
attacks the first model's work instead of producing a correlated duplicate of it.

**One hard rule: Opus 4.8 always drafts and always owns the final fuse — the chain can't be reversed.**
The checker can't call back out to spawn Opus, so Opus is always the driver. The slug reads
driver-first for exactly this reason.

## Step 0 — Pick the chain

Run the detector to see which checker CLIs exist on this machine:

```bash
bash <skill_dir>/scripts/detect_panel.sh
```

It prints a `SLUG=` line recommending the richest chain currently possible:

| Slug | Chain | Requires |
| --- | --- | --- |
| `opus4.8-4.8` | Opus drafts → 2nd Opus 4.8 checks → Opus fuses | nothing — always available |
| `opus4.8-gpt5.5` | Opus drafts → GPT-5.5 checks → Opus fuses | `codex` CLI |
| `opus4.8-gpt5.5-gemini3.1pro` | Opus drafts → GPT-5.5 checks → Gemini checks → Opus fuses | `codex` + `gemini` CLIs |

If the user named a slug, honor it — but if a required CLI is missing, say so, drop that checker, and
fall back to the next-richest chain rather than failing. Otherwise use the detector's recommendation.

## Step 1 — Generate (Opus 4.8)

Read `references/roles.md`. As the generator, write a **complete, self-contained draft answer** to the
user's task: research with web search, verify with bash where you can, and make your reasoning, key
commands, and sources visible enough that a second model can audit them. This is your genuine best
attempt — the checker will scrutinize it. Keep the full draft text; you'll hand it to the checker(s)
and use it again when you fuse.

## Step 2 — Check (the second model)

Build the checker prompt per `references/roles.md`: the checker role, the user's task **verbatim**, and
a clearly delimited block with your full draft. Instruct it to *independently verify with its own web +
bash, then report confirmations, corrections, gaps, and blind spots — not rubber-stamp*. Then run it:

- **Opus 4.8 checker** (`opus4.8-4.8`) → the `Agent` tool, `subagent_type: general-purpose` (web + bash
  built in). Pass the checker prompt; its returned text is the critique.
- **GPT-5.5 checker** (`opus4.8-gpt5.5`) → write the checker prompt to a temp file and run:
  ```bash
  bash <skill_dir>/scripts/run_codex.sh /tmp/fusion_codex_prompt.txt /tmp/fusion_codex_out.md medium
  ```
  `-o` makes codex write only its final critique to the out file; read it once done.
- **Gemini checker** (3-model slug) → `bash <skill_dir>/scripts/run_gemini.sh /tmp/fusion_gemini_prompt.txt /tmp/fusion_gemini_out.md`.
  Exit 127 means the CLI isn't installed — drop Gemini and note the chain downgraded.

With more than one checker, each checks the **original draft independently** — don't feed one checker's
notes into the next, or their critiques stop being independent.

## Step 3 — Fuse (Opus 4.8)

Read `references/fusion_rubric.md` and merge the draft with the checker(s)' critiques. Read each critique
in full, decide point by point whether the checker was right (a checker that ran code or cited a primary
source outranks the draft — including when the draft was yours; don't rubber-stamp your own work), and
produce exactly these sections: **Confirmed**, **Corrections**, **Contradictions (unresolved)**, **Gaps
filled**, **Blind spots**, then a **Final answer**. Attribute findings to the checker by model so the
user can see what changed and why.

## Step 4 — Present

Lead with the **Final answer**, then the audit trail beneath it. Name the slug you ran and which models
participated. If the chain downgraded because a CLI was missing, say so and how to enable the fuller
chain (install the missing CLI).

## Cost & latency note

A Fusion run costs roughly 2–3× a single answer in tokens and adds the checker's wall-clock time. That's
the trade: you pay more to stop being confidently wrong where that's expensive. For quick or low-stakes
questions, a single direct answer is the right call — don't reach for Fusion when one pass would do.

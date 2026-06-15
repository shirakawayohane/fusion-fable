---
name: fusion
description: >-
  Answer a hard question by fanning it out to a two-model PANEL running in parallel — Opus 4.8 and GPT-5.5
  each answering independently with web search and bash, neither seeing the other's work — then having
  Opus 4.8 judge both responses into a structured analysis (consensus, contradictions, partial coverage,
  unique insights, blind spots) and write a final answer grounded in it. Opus always judges and writes the
  final answer — the pipeline can't be reversed. Use this whenever the user asks to "run it through
  Fusion", wants a multi-model / panel / ensemble answer, wants a question cross-checked across models, or
  wants a higher-confidence answer with consensus and blind spots surfaced — even if they don't say
  "fusion". Best for high-stakes research, design calls, and debugging where being confidently wrong is
  expensive.
---

# Fusion

Fusion turns one prompt into a two-model panel. The question goes to **Opus 4.8 and GPT-5.5 at the same
time**, each answering independently — with web search and bash, and with no knowledge of the other. Then
Opus 4.8 reads both answers, extracts the structure of the panel's reasoning (what they agree on, where
they conflict, what only one saw, what they both missed), and writes a final answer grounded in that
analysis.

The whole mechanism is **independence, then synthesis**. The diversity that makes a panel beat a single
model is harvested, not manufactured: two models working the same prompt cold produce different reasoning
paths, tool calls, and sources. So there are no assigned "lenses" or personas; each panelist gets the
user's task verbatim and answers it straight. (See `references/panel.md`.)

**One hard rule: Opus 4.8 always judges and writes the final answer — the pipeline can't be reversed.**
GPT-5.5 can't call back out to spawn Opus, so Opus is always the driver.

GPT-5.5 runs via the `codex` CLI (`codex exec`), which is assumed to be installed and logged in — this is
a manual tool, so there's no availability check to slow you down. Just fan out.

This skill mirrors OpenRouter Fusion's pipeline — **fan out → structured analysis → synthesize**, a single
round — and like the API, **the synthesized answer is the deliverable**: there is no separate "now I'll
build/execute it myself" phase after the panel. The panel runs on the actual deliverable, not on a plan you
then carry out alone.

## Step 1 — Fan out, in parallel and blind

Read `references/panel.md`. Build each panelist's prompt as the user's task **verbatim** plus the short
instruction to research with web + bash and return a complete, self-contained answer as one of two
independent experts who won't see the other's work. Do not assign lenses; do not pre-digest the task.

Launch **both panelists in a single turn** so they run concurrently:

- **Opus 4.8 panelist** → the `Agent` tool, `subagent_type: general-purpose` (web + bash built in).
- **GPT-5.5 panelist** → write its prompt to a temp file and run in the background. Use a unique pair of
  paths (e.g. `mktemp`) so concurrent runs don't clobber each other:
  ```bash
  p=$(mktemp /tmp/fusion_codex_prompt.XXXXXX); o=$(mktemp /tmp/fusion_codex_out.XXXXXX)
  # write the verbatim panelist prompt to "$p", then:
  bash <skill_dir>/scripts/run_codex.sh "$p" "$o" high
  ```
  The runner pins the model to GPT-5.5 and defaults to high reasoning effort. `-o` makes codex write only
  its final answer to the out file; read it once it finishes.

Keep the panelists isolated: never paste one panelist's output into the other's prompt. The orchestrator
(you) is the judge and must stay separate from the panelists — the Opus panelist is a spawned subagent,
not you, so your synthesis reads both answers fresh.

**Panel size.** OpenRouter Fusion defaults to a 3-model panel and allows 1–8. Here the default panel is 2
— Opus 4.8 + GPT-5.5 — which the API treats as valid (even self-fusion, Opus×Opus, lifts quality). Scale
toward the API when the stakes warrant by adding panelist draws (e.g. a second independent Opus draw);
every panelist still runs in parallel, blind, on the verbatim task. More panelists = proportionally more
cost.

## Step 2 — Judge: structured analysis (always, one round)

Once all panelists have returned, read `references/judge_rubric.md` and produce the **structured analysis**
— the same shape OpenRouter Fusion returns, the *same way regardless of whether the task is research or
code*:

- **Consensus** — points all/most panelists independently agree on (your highest-confidence signal).
- **Contradictions** — direct disagreements; adjudicate by evidence (who ran the code / read the primary
  source), and if you can't resolve it, say so and name what would settle it.
- **Partial coverage** — sub-questions only some panelists engaged.
- **Unique insights** — non-obvious points exactly one panelist raised. Preserve them.
- **Blind spots** — what the panel as a whole missed; add one of your own if you see it.

Attribute every point by panelist (Opus 4.8 / GPT-5.5). A panelist that failed counts as **absent**, never
as silent agreement. Evidence outranks assertion: weight a panelist that actually ran code or read a source
over one reasoning from memory.

This analysis is a **mandatory intermediate** — you write it before the final answer, every time. It is the
mechanism that forces each panelist's content (including the second model's) into the result. Skip it and
the panel collapses into a single-model answer with a sanity-check stapled on.

## Step 3 — Synthesize: the analysis becomes the deliverable

The calling model (you, Opus 4.8) writes the **final answer grounded in that analysis** — lead with
high-confidence consensus, fold in the unique insights, flag what stays uncertain. It must follow *from* the
synthesis, not be one panelist's answer lightly edited.

**The synthesized answer IS the deliverable.** Mirroring the API, there is no separate "now I'll just
build/execute it myself" phase after the panel — the fused answer is the output. Two checks:

- If the task is multi-step and too large for one panel, the panel is the unit of *each* hard decision:
  re-fan-out per fork rather than paneling once up front and finishing alone.
- If your final carries nothing that only another panelist surfaced, you under-used the panel — re-read
  their answers before you ship.

For a runnable artifact you may **verify** the synthesized result by building/running it (and fix until it
passes, stating what you ran) — but it still flows *from* the structured analysis, not from soloing one
candidate.

## Step 4 — Present

Lead with the **final answer**, then the audit trail beneath it: the five-section structured analysis with
per-panelist attribution, and — if you verified by running — what you ran and observed. Note which panelists
participated (e.g. Opus 4.8 + GPT-5.5).

## Single round & recursion protection

Fusion is **one round**. Panelists and the judge must not invoke Fusion again — no nested or recursive
fusion, no multi-round re-deliberation within a single run. Fan out once, analyze, synthesize, done.

## Cost & latency note

A two-model panel costs roughly 2× a single answer in tokens and runs as slow as its slowest panelist.
That's the deliberate trade: you spend more to stop being confidently wrong where that's expensive.

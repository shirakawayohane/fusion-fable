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

## Step 2 — Judge (pick the track that fits the task)

Once both panelists have returned, read `references/judge_rubric.md` and **classify the deliverable
first**, because code and prose merge completely differently:

- **Artifact task** (code, script, config, Minecraft mod/datapack, schema — the user wants a buildable
  thing) → **Track A: run both, then merge**. You are integrating two *implementations* into one working
  program, not writing a report. **Run each candidate with bash first** to see what actually works and what
  breaks in each, decide what to keep based on observed behavior (not on which looks better), graft the
  parts that worked onto the stronger base, then **run the merged result and fix until it passes**. The
  panel's value here is that two independent attempts expose each other's bugs — running both is how you
  find which one is actually right, so the merge ends up **more correct than either input**. (If it truly
  can't be executed here — needs the live game or an unavailable toolchain — fall back to seam-reasoning
  and mark it unverified.)
- **Research / analysis task** (the user wants understanding or a recommendation) → **Track B: structured
  synthesis** — the five sections: **Consensus**, **Contradictions**, **Partial coverage**, **Unique
  insights**, **Blind spots**. Don't average or smooth over conflict; independent agreement is your
  highest-confidence signal, honest disagreement is the most useful thing the panel produces.

Either way: attribute decisions to each panelist (Opus 4.8 / GPT-5.5), and weight a panelist that actually
ran the code or read a primary source over one reasoning from memory. If a panelist failed, the judge
treats it as **absent** — never as silent agreement.

## Step 3 — Final deliverable

- **Track A (code/artifact):** emit the complete, merged artifact — every file, ready to run as-is, not a
  diff or "take Opus's X and GPT's Y." Per `judge_rubric.md`, you got here by **running both candidates**
  and keeping what worked, and you **run the merged result and fix it until it passes** before presenting.
  Follow with a tight merge rationale: what each candidate did when run, what you took from each, and what
  you verified.
- **Track B (research):** write the answer grounded in the structured analysis — lead with high-confidence
  consensus, fold in unique insights, flag what stays uncertain. It must follow *from* the synthesis, not
  be one panelist's answer lightly edited.

## Step 4 — Present

Lead with the **final deliverable** — the merged working artifact (Track A) or the grounded answer
(Track B) — then the audit trail beneath it: for code, what each candidate did when run + the merge
rationale + what you verified; for research, the five-section analysis. Note which panelists participated
(Opus 4.8 + GPT-5.5).

## Cost & latency note

A two-model panel costs roughly 2× a single answer in tokens and runs as slow as its slowest panelist.
That's the deliberate trade: you spend more to stop being confidently wrong where that's expensive. For
quick or low-stakes questions, a single direct answer is the right call — don't reach for Fusion when one
model would obviously do.

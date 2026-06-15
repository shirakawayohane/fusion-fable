# Fusion-Fable

**Fuse Opus 4.8 + GPT-5.5 into one Fable-tier answer.**

Fusion-Fable is a [Claude Code](https://claude.com/claude-code) skill that runs a hard question through a
**panel → judge** pipeline. The same prompt is dispatched to **Opus 4.8 and GPT-5.5 in parallel** — each
answering independently with web search and bash, neither seeing the other's work — and then Opus 4.8
judges both answers into a structured analysis (consensus, contradictions, partial coverage, unique
insights, blind spots) and writes a final answer grounded in it.

The mechanism is **independence, then synthesis**. The diversity that makes a panel beat a single model is
harvested, not manufactured: two models running the same prompt independently yield different reasoning
paths, tool calls, and sources, and synthesizing them beats running either alone. So there are no contrived
"lenses" or personas; both panelists get the task verbatim and answer it straight.

```
                      ┌──────────────┐
                 ┌──▶ │   Opus 4.8   │ ─┐   (web + bash, independent)
 prompt ──▶ fan ─┤    └──────────────┘  │   ┌──────────────┐
            out  │    ┌──────────────┐  ├─▶ │   Opus 4.8   │ ──▶ final answer
                 └──▶ │   GPT-5.5    │ ─┘   │   (judge +   │     (grounded in
                      │   (codex)    │      │  synthesize) │      the analysis)
                      └──────────────┘      └──────────────┘
                  each answers blind        consensus · contradictions ·
                                            partial · unique · blind spots
```

Opus 4.8 **always** judges and writes the final answer — the pipeline can't be reversed, because GPT-5.5
can't call back out to spawn Opus.

## Install

```bash
git clone https://github.com/duolahypercho/fusion-fable.git
cd fusion-fable
./install.sh
```

This copies the skill to `~/.claude/skills/fusion` and the `/fusion` slash command to `~/.claude/commands`,
then checks whether the `codex` CLI (for GPT-5.5) is available. Restart Claude Code (or run
`/reload-skills`) afterward.

> Override the target with `CLAUDE_CONFIG_DIR=/path/to/.claude ./install.sh`.

## Use it

Three ways, all equivalent under the hood:

- **Natural language** — just ask. The skill auto-triggers:
  > "Run this through Fusion: is it safe to `ALTER TABLE … ADD COLUMN` on a 200M-row Postgres table in prod?"
- **Slash command:**
  ```
  /fusion  is git push --force-with-lease actually safe on a shared branch?
  ```
- **In prose** — "run the Fusion panel on …".

Every run returns the same structure: a **Final answer** up top, then the audit trail —
**Consensus / Contradictions / Partial coverage / Unique insights / Blind spots** — with each point
attributed to the panelist that raised it (Opus 4.8 or GPT-5.5), so you can see how the answer was
assembled.

## Requirements

- **Claude Code**, with the session running **Opus 4.8** (the Opus panelist subagent and the judge inherit
  the session model).
- The [`codex` CLI](https://github.com/openai/codex) installed and logged in to an account with GPT-5.5
  access. The runner uses `codex exec` (tested against `codex-cli` 0.139). If `codex` is missing, the skill
  stops and tells you how to enable it rather than answering with a single model — the panel is the point.

## What's in here

```
skills/fusion/
  SKILL.md                  fan out Opus 4.8 + GPT-5.5 in parallel → judge → grounded final answer
  scripts/
    run_codex.sh            runs the GPT-5.5 panelist (web + bash), captures its answer
  references/
    panel.md                why independent parallel runs (no lenses) — the panel mechanism
    judge_rubric.md         the structured analysis + grounded final answer
commands/
  fusion.md                 /fusion  (Opus 4.8 + GPT-5.5 panel)
install.sh                  copies the above into ~/.claude
```

## Why a panel beats one model

On the DRACO deep-research benchmark, OpenRouter found that fusing model answers consistently beats the
individual models — and that a meaningful chunk of the lift comes from the *synthesis step itself*, not
just from mixing architectures. Fusion-Fable implements that same independence-then-judge pipeline locally
in Claude Code, with Opus 4.8 and GPT-5.5 as the panel.

## Cost & latency

A two-model panel costs roughly 2× a single answer in tokens and runs as slow as its slowest panelist.
That's the deliberate trade: spend more to stop being confidently wrong where that's expensive. For quick
or low-stakes questions, a single direct answer is the right call.

## License

MIT — see [LICENSE](LICENSE).

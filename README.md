# Fusion-Fable

**Fuse two frontier models into one Fable-tier answer.**

Fusion-Fable is a [Claude Code](https://claude.com/claude-code) skill that runs a hard question
through a two-stage **generate → check → fuse** chain. One Opus 4.8 drafts a complete answer; a
*second* model independently checks it — re-verifying with its own web search and bash, correcting
errors, filling gaps, surfacing blind spots — and then Opus fuses the draft and the critique into one
higher-confidence final answer.

The bet is simple: an answer that has survived a second model's scrutiny is worth more than either
model's first guess. Fuse **Opus 4.8 + Opus 4.8**, or **Opus 4.8 + GPT-5.5** (via the `codex` CLI),
into a result better than either alone — a Fable-tier fusion.

```
            ┌──────────────┐      draft       ┌──────────────┐     critique      ┌──────────────┐
 prompt ──▶ │  Opus 4.8    │ ───────────────▶ │   checker    │ ────────────────▶ │   Opus 4.8   │ ──▶ fused answer
            │  (generate)  │   (web + bash)   │ (independent │   (web + bash)    │    (fuse)    │
            └──────────────┘                  │  verify)     │                   └──────────────┘
                                              └──────────────┘
                                          Opus / GPT-5.5 / Gemini
```

Opus 4.8 **always** drafts and owns the final fuse — the chain can't be reversed, because the checker
can't call back out to spawn Opus.

## The chains

| Slug | Chain | Requires |
| --- | --- | --- |
| `opus4.8-4.8` | Opus drafts → a **second Opus 4.8** checks → Opus fuses | nothing — works everywhere |
| `opus4.8-gpt5.5` | Opus drafts → **GPT-5.5** (codex) checks → Opus fuses | the `codex` CLI |
| `opus4.8-gpt5.5-gemini3.1pro` | Opus drafts → GPT-5.5 checks → **Gemini 3.1 Pro** checks → Opus fuses | `codex` + `gemini` CLIs |

The skill auto-detects which checker CLIs are installed and uses the richest chain available, falling
back gracefully when one is missing.

## Install

```bash
git clone https://github.com/duolahypercho/fusion-fable.git
cd fusion-fable
./install.sh
```

This copies the skill to `~/.claude/skills/fusion` and the slash commands to `~/.claude/commands`,
then prints which chains your machine can run. Restart Claude Code (or run `/reload-skills`) afterward.

> Override the target with `CLAUDE_CONFIG_DIR=/path/to/.claude ./install.sh`.

## Use it

Three ways, all equivalent under the hood:

- **Natural language** — just ask. The skill auto-triggers and picks the richest chain:
  > "Run this through Fusion: is it safe to `ALTER TABLE … ADD COLUMN` on a 200M-row Postgres table in prod?"
- **Pinned slash commands:**
  ```
  /fusion-opus4.8  does my JWT refresh-rotation design have a replay hole?
  /fusion-gpt5.5   is git push --force-with-lease actually safe on a shared branch?
  ```
- **Force a chain in prose** — "run the `opus4.8-gpt5.5` Fusion on …".

Every run returns the same structure: a **Final answer** up top, then the audit trail —
**Confirmed / Corrections / Contradictions / Gaps filled / Blind spots** — with each finding attributed
to the checker model, so you can see exactly what the second model changed.

## Requirements

- **Claude Code**, with the session running **Opus 4.8** (the generator and the Opus checker inherit the
  session model — on another model the slug is nominal, not literal).
- For `opus4.8-gpt5.5`: the [`codex` CLI](https://github.com/openai/codex) installed and logged in to an
  account with GPT-5.5 access. The runner uses `codex exec` (tested against `codex-cli` 0.139).
- For the 3-model chain: a `gemini` CLI installed and authenticated. Adjust the invocation in
  `skills/fusion/scripts/run_gemini.sh` to match your CLI's flags.

Only the **`opus4.8-4.8`** chain is truly zero-setup; the GPT-5.5 and Gemini chains light up once their
CLIs are installed and authenticated.

## What's in here

```
skills/fusion/
  SKILL.md                  generate → check → fuse orchestration
  scripts/
    detect_panel.sh         picks the richest available chain
    run_codex.sh            runs the GPT-5.5 checker (web + bash), captures its critique
    run_gemini.sh           runs the Gemini checker (graceful no-op until the CLI exists)
  references/
    roles.md                generator vs checker roles
    fusion_rubric.md        the fuse output structure
commands/
  fusion-opus4.8.md         /fusion-opus4.8  (pinned opus4.8-4.8 chain)
  fusion-gpt5.5.md          /fusion-gpt5.5   (pinned opus4.8-gpt5.5 chain)
install.sh                  copies the above into ~/.claude
```

## Cost & latency

A Fusion run costs roughly 2–3× a single answer in tokens and adds the checker's wall-clock time. That's
the deliberate trade: spend more to stop being confidently wrong where that's expensive. For quick or
low-stakes questions, a single direct answer is the right call.

## License

MIT — see [LICENSE](LICENSE).

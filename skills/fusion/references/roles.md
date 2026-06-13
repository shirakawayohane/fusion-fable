# Fusion roles

Fusion is a **two-stage chain**, not a parallel panel: one model drafts an answer, then another model
checks and fuses on top of it. There are exactly two roles.

## Generator (always Opus 4.8)

Produces the first, complete draft answer to the user's task. Researches with web search, verifies
with bash where it can, and writes a full self-contained answer — not an outline. This is the answer
the checker will scrutinize, so it should be the generator's genuine best attempt, with its reasoning
and any commands/sources visible enough that a second model can audit them.

The orchestrator (you, Opus 4.8) is the generator. You also own the final fuse — but keep those two
phases honest: when you fuse, you are auditing your *own* draft through the checker's eyes, so take the
checker's corrections seriously rather than defending the draft.

## Checker (the second model named in the slug)

Receives the user's task **and** the generator's draft, and independently pressure-tests it. The
checker's job is not to agree — it's to find what's wrong, missing, or unverified:

- Re-derive or re-research the answer with its *own* web search + bash, rather than trusting the draft.
  Where it can run code or read a primary source, it should, and report what it actually observed.
- Flag factual errors, unsupported claims, and reasoning gaps in the draft, with the correction.
- Add coverage the draft missed — sub-questions, edge cases, caveats.
- Name blind spots the draft (and the checker's own first instinct) shared.
- Where it agrees, say so explicitly and why — confirmation from an independent model is a real signal.

A checker that just says "looks good" has failed. Give it explicit license to disagree with the draft.

## The chain

- `opus4.8-4.8` — Opus drafts → a second **Opus 4.8** (Agent subagent) checks → Opus fuses.
- `opus4.8-gpt5.5` — Opus drafts → **GPT-5.5** (codex) checks → Opus fuses.
- `opus4.8-gpt5.5-gemini3.1pro` — Opus drafts → **GPT-5.5** checks → **Gemini 3.1 Pro** checks → Opus fuses.

With multiple checkers, each checks the **original draft independently** (don't feed one checker's notes
to the next — keep their critiques uncorrelated). The fuser reconciles all of them at the end.

## Prompt assembly

- **Generator prompt** = instruction to answer fully, verifying with web + bash, returning a complete
  self-contained answer + the user's task **verbatim**.
- **Checker prompt** = the checker role above + the user's task verbatim + a clearly delimited block
  containing the generator's full draft, with the instruction: *independently verify, then report
  confirmations, corrections, gaps, and blind spots — don't rubber-stamp.*

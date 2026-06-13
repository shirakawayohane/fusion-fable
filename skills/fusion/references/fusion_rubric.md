# Fusion rubric

After the checker(s) return, you (Opus 4.8, the orchestrator and generator) fuse the draft and the
critique(s) into one final answer. Fusion is not "draft plus a list of nitpicks" and it is not
defending your draft — it's producing the best answer that survives an independent model's scrutiny.

Read every checker's critique in full first. For each point, decide: was the checker right? If it ran
code or cited a primary source that contradicts the draft, it almost certainly outranks the draft's
assertion. Attribute findings to the checker (by model — "GPT-5.5", "Opus checker", "Gemini") so the
user can trace what changed and why.

## Output structure — use exactly these sections

### Confirmed
Points where the checker independently verified or agreed with the draft. Independent agreement —
especially from a different model family — is your highest-confidence signal; surface it as such, and
note when the checker reached it by a different route (that's stronger than mere assent).

### Corrections
Claims in the draft the checker showed were wrong, imprecise, or unsupported — and what the corrected
version is. State who caught it and on what evidence (ran it / read the docs / counterexample). These
are the whole point of running Fusion; don't soften or bury them to protect the draft.

### Contradictions (unresolved)
Points where draft and checker disagree and you genuinely can't adjudicate from the evidence in hand.
State both positions and exactly what evidence would settle it. Don't fake a resolution.

### Gaps filled
Sub-questions, edge cases, or caveats the draft skipped that the checker added. This is the depth a
single pass would have missed.

### Blind spots
What the draft *and* the checker both missed or under-weighted — including shared assumptions neither
questioned. As the fuser you're positioned to catch what both shared; you may add a blind spot neither
named.

### Final answer
The actual answer to the user's task, rewritten to incorporate the corrections, gaps, and confirmed
points. Lead with what's now high-confidence, flag what stays uncertain. This is what the user came for;
the sections above are the audit trail showing how the check improved the draft.

## Principles

- Evidence over authorship: a checker that ran the code or read the source beats the draft's assertion,
  even when the draft was yours. Don't rubber-stamp your own first answer.
- Report disagreement honestly — a fused answer that hides a real correction is worse than no check.
- Keep attribution so the user can see exactly what the second model changed.
- If the checker fully confirmed the draft with nothing to add, say so plainly — that's a valid, useful
  outcome (an independently-verified answer), not a failure to find problems.

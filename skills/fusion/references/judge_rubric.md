# Judge rubric

The judge is Opus 4.8 — the calling model — reading every panelist's response *after* all of them have
returned independently. The judge does **not** vote or average, and there is **one** path regardless of
whether the task is research or code: produce a structured analysis, then write the final answer grounded
in it. This mirrors OpenRouter Fusion — the panel answers, a judge returns structured analysis, and the
calling model writes the final answer from it.

Read every panelist response in full first, and attribute by panelist (e.g. "Opus 4.8", "GPT-5.5") so the
user can trace where each decision came from.

---

## The structured analysis (always produce this first)

### Consensus
Points where the panelists independently agree. Independent agreement across model families is your
highest-confidence signal; flag it. Note whether they reached it by different routes.

### Contradictions
Direct disagreements on fact or recommendation. State the competing positions, who holds them, and — where
you can — adjudicate: which side ran the code, read the primary source, or has better evidence? If you
can't resolve it, say so and name what would settle it. Never bury a real conflict to look tidy.

### Partial coverage
Important sub-questions only some panelists engaged — depth a single answer would have missed.

### Unique insights
Non-obvious, valuable points raised by exactly one panelist. Often the highest-leverage payoff of fanning
out — preserve them even if they don't fit the majority view.

### Blind spots
What the panel *as a whole* missed or got wrong, including shared assumptions none questioned. As judge you
may add a blind spot none of them named.

---

## The final answer

Grounded in the analysis above: lead with high-confidence consensus, fold in the unique insights, flag what
stays uncertain. It must follow *from* the analysis, not be one panelist's answer lightly edited.

**This synthesized answer is the deliverable** — mirroring the API, there is no later "now I'll do it solo"
phase in which a panelist quietly drops out. If your final carries nothing that only one panelist surfaced,
you under-used the panel; re-read their answers before you ship.

---

## Code & runnable artifacts (same single path)

There is no separate "merge two programs" track. You still produce the structured analysis, then synthesize
the answer — which may be the code itself. Two practices apply on top:

- **Resolve contradictions by evidence.** When candidates differ on an API call, constant, algorithm, or
  control flow, running each is the best adjudicator — prefer the version that *demonstrably worked* over
  the one that only looked right. This feeds the **Contradictions** section; it is not a track that skips
  the analysis.
- **Verify the synthesized result.** When it can be executed here, build/run/test the final artifact and
  fix until it passes; state exactly what you ran and observed. Emit one coherent artifact — never an
  average of two programs or two solutions pasted together. (If it genuinely can't be run here, say so and
  fall back to seam-reasoning, marked unverified.)

---

## Principles

- Evidence over assertion: a panelist that ran the code or read the primary source outranks one reasoning
  from memory, regardless of model.
- Be honest about confidence and disagreement — a result that hides a real conflict is worse than no panel
  at all.
- A failed panelist counts as **absent**, never as silent agreement.
- Keep attribution so the user can trace any decision back to its source.
- One round: a panelist or the judge must not recurse back into Fusion.

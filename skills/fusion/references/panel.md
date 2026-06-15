# The panel

Fusion's power comes from **independent answers, synthesized** — not from a clever prompt or assigned
personas. You dispatch the same question to Opus 4.8 and GPT-5.5 at once, each works the problem cold with
no knowledge of the other, and Opus 4.8 fuses their answers. Independent agreement is high-confidence;
independent disagreement is exactly the signal worth surfacing.

## No lenses, no personas

Do not assign panelists "roles" or "stances" (skeptic, optimizer, first-principles, etc.). That biases
*how* each one reasons artificially and corrupts the very independence that makes the panel work. Pass
both panelists the user's task **verbatim** and let each answer it straight.

The diversity is already there for free. Two different models running the same prompt produce different
reasoning paths, different tool calls, and different source selections. You don't manufacture diversity;
you harvest it from independence.

## Independence is the rule

Panelists must never see each other's work. Don't show one panelist the other's answer, and don't let the
orchestrator pre-digest or summarize the task before handing it over. The judge is the only place the
answers meet. Cross-pollination before the judge defeats the entire mechanism.

## Panel composition

Opus 4.8 (an Agent subagent) and GPT-5.5 (via the `codex` CLI) answer **in parallel**, then Opus 4.8
judges. Opus 4.8 is also the judge/synthesizer, and the judge is kept separate from the panelists (the
Opus panelist is a spawned subagent; the orchestrator judges) so the synthesis reads both answers fresh
rather than defending one it wrote itself. Opus always judges and writes the final answer — the pipeline
can't be reversed, since GPT-5.5 can't call back out to spawn Opus.

This 2-model panel is the default; OpenRouter Fusion itself defaults to 3 models and allows 1–8. Scale up
by adding independent panelist draws (even a second Opus draw — self-fusion still lifts quality) when the
stakes justify the extra cost. Whatever the count, every panelist answers in parallel, blind, on the
verbatim task.

## Prompt each panelist gets

Each panelist receives the user's task **verbatim**, plus a short instruction: *research with web search
and bash, then return a complete, self-contained answer; you are one of two independent experts and will
not see the other's work.* Nothing more — no lens, no framing that nudges the conclusion.

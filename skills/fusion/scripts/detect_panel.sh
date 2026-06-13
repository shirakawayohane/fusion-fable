#!/usr/bin/env bash
# detect_panel.sh — figure out which checker CLIs are installed and recommend a Fusion chain.
#
# Fusion is a chain: Opus 4.8 drafts, a second model CHECKS, Opus fuses. Opus 4.8 is always the
# generator + fuser and is always available via the Agent tool (in-process subagents) — so it never
# needs a CLI check. This script only probes the *external checker* CLIs (GPT-5.5 via codex, Gemini
# via gemini) and prints the richest slug the machine can currently support.
#
# Output: human-readable lines + a final `SLUG=...` line the orchestrator can grep.

have() { command -v "$1" >/dev/null 2>&1; }

codex_ok=false; gemini_ok=false
have codex  && codex_ok=true
have gemini && gemini_ok=true

echo "checker availability (generator is always Opus 4.8 via Agent subagents):"
echo "  opus4.8  : yes (Agent subagent — always available)"
printf "  gpt5.5   : %s (codex CLI)\n"  "$([ "$codex_ok"  = true ] && echo yes || echo NO)"
printf "  gemini3.1pro : %s (gemini CLI)\n" "$([ "$gemini_ok" = true ] && echo yes || echo NO)"
echo

if   $codex_ok && $gemini_ok; then slug="opus4.8-gpt5.5-gemini3.1pro"
elif $codex_ok;                then slug="opus4.8-gpt5.5"
else                                slug="opus4.8-4.8"
fi

echo "recommended chain: $slug"
echo "SLUG=$slug"

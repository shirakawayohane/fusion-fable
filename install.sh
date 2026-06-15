#!/usr/bin/env bash
# install.sh — install the Fusion-Fable skill + slash command into your Claude Code config.
#
# Copies:
#   skills/fusion        -> $CLAUDE_DIR/skills/fusion
#   commands/*.md         -> $CLAUDE_DIR/commands/
# where CLAUDE_DIR defaults to ~/.claude (override with CLAUDE_CONFIG_DIR).

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/commands"

rm -rf "$CLAUDE_DIR/skills/fusion"
cp -R "$HERE/skills/fusion" "$CLAUDE_DIR/skills/fusion"
cp "$HERE/commands/"*.md "$CLAUDE_DIR/commands/"
chmod +x "$CLAUDE_DIR/skills/fusion/scripts/"*.sh

echo "✓ Installed Fusion-Fable into $CLAUDE_DIR"
echo "    skill   : $CLAUDE_DIR/skills/fusion"
echo "    command : /fusion"
echo

# The panel is Opus 4.8 + GPT-5.5; GPT-5.5 needs the 'codex' CLI.
have() { command -v "$1" >/dev/null 2>&1; }
if have codex; then
  echo "Panel ready: Opus 4.8 + GPT-5.5 (codex found: $(codex --version 2>/dev/null | head -1))"
else
  echo "Panel needs the 'codex' CLI for GPT-5.5 — install it and log in to an account with GPT-5.5 access."
fi
echo
echo "Next: restart Claude Code (or run /reload-skills) so 'fusion' and the /fusion command load."

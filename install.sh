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
echo "Panel: Opus 4.8 + GPT-5.5 (GPT-5.5 via the 'codex' CLI)."
echo "Next: restart Claude Code (or run /reload-skills) so 'fusion' and the /fusion command load."

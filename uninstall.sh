#!/bin/bash
# simple-peon-ping uninstaller
set -euo pipefail

INSTALL_DIR="$HOME/.claude/hooks/simple-peon-ping"
SETTINGS="$HOME/.claude/settings.json"

echo "=== simple-peon-ping uninstaller ==="
echo ""

if [ -f "$SETTINGS" ] && command -v jq &>/dev/null; then
  echo "Removing hooks from settings.json..."
  jq '
    .hooks |= (
      to_entries
      | map(.value |= map(select(
          .hooks | map(.command // "" | test("peon\\.sh")) | any | not
        )))
      | map(select(.value | length > 0))
      | from_entries
    )
  ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
  echo "Done"
fi

if [ -d "$INSTALL_DIR" ]; then
  echo "Removing $INSTALL_DIR..."
  rm -rf "$INSTALL_DIR"
  echo "Done"
fi

echo ""
echo "Me go now."

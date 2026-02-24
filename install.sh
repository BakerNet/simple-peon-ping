#!/bin/bash
# simple-peon-ping installer
set -euo pipefail

INSTALL_DIR="$HOME/.claude/hooks/simple-peon-ping"
SETTINGS="$HOME/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_URL="https://sounds.spriters-resource.com/media/assets/422/425494.zip"
SOURCE_SUBFOLDER="Orc/Peon"

echo "=== simple-peon-ping installer ==="
echo ""

# Prerequisites
if [ ! -d "$HOME/.claude" ]; then
  echo "Error: ~/.claude not found — is Claude Code installed?"
  exit 1
fi

# Install hook script
echo "Installing to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/peon.sh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/peon.sh"

# Download and organize sounds
echo ""
echo "Downloading sounds..."
TMPDIR_DL=$(mktemp -d)
TMPDIR_EX=$(mktemp -d)
trap 'rm -rf "$TMPDIR_DL" "$TMPDIR_EX"' EXIT

if ! curl -L --progress-bar -o "$TMPDIR_DL/sounds.zip" "$SOURCE_URL"; then
  echo ""
  echo "Download failed. Manually download the ZIP from:"
  echo "  $SOURCE_URL"
  echo "Extract the '$SOURCE_SUBFOLDER' folder contents and re-run."
  exit 1
fi

echo "Extracting..."
unzip -q -j "$TMPDIR_DL/sounds.zip" "$SOURCE_SUBFOLDER/*.wav" -d "$TMPDIR_EX"

echo "Organizing by category..."
mkdir -p "$INSTALL_DIR/sounds/"{greeting,acknowledge,complete,permission,error}

cp "$TMPDIR_EX/PeonReady1.wav" "$TMPDIR_EX/PeonWhat1.wav" "$TMPDIR_EX/PeonWhat3.wav" \
   "$INSTALL_DIR/sounds/greeting/"

cp "$TMPDIR_EX/PeonYes1.wav" "$TMPDIR_EX/PeonYes2.wav" "$TMPDIR_EX/PeonYes3.wav" \
   "$TMPDIR_EX/PeonYes4.wav" "$TMPDIR_EX/PeonYesAttack1.wav" \
   "$TMPDIR_EX/PeonYesAttack2.wav" "$TMPDIR_EX/PeonYesAttack3.wav" \
   "$INSTALL_DIR/sounds/acknowledge/"

cp "$TMPDIR_EX/PeonReady1.wav" "$TMPDIR_EX/PeonWhat1.wav" "$TMPDIR_EX/PeonYes1.wav" \
   "$TMPDIR_EX/PeonYes2.wav" "$TMPDIR_EX/PeonYes3.wav" \
   "$TMPDIR_EX/PeonYesAttack1.wav" "$TMPDIR_EX/PeonYesAttack3.wav" \
   "$INSTALL_DIR/sounds/complete/"

cp "$TMPDIR_EX/PeonWhat1.wav" "$TMPDIR_EX/PeonWhat2.wav" \
   "$TMPDIR_EX/PeonWhat3.wav" "$TMPDIR_EX/PeonWhat4.wav" \
   "$INSTALL_DIR/sounds/permission/"

cp "$TMPDIR_EX/PeonAngry4.wav" "$TMPDIR_EX/PeonDeath.wav" \
   "$INSTALL_DIR/sounds/error/"

# Register hooks in settings.json
echo ""
echo "Registering hooks..."
HOOK_CMD="$INSTALL_DIR/peon.sh"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"

jq --arg cmd "$HOOK_CMD" '
  def upsert(event):
    .hooks[event] = (
      (.hooks[event] // [])
      | map(select(.hooks | map(.command // "" | test("peon\\.sh")) | any | not))
      | . + [{"matcher": "", "hooks": [{"type": "command", "command": $cmd, "timeout": 10}]}]
    );
  upsert("SessionStart") | upsert("UserPromptSubmit") | upsert("PostToolUseFailure") | upsert("Notification")
' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

echo "Hooks registered for: SessionStart, UserPromptSubmit, PostToolUseFailure, Notification"
echo ""
echo "=== Installation complete! ==="
echo "Zug zug."

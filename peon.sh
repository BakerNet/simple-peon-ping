#!/bin/bash
# simple-peon-ping: Warcraft III Peon voice lines for Claude Code hooks
set -uo pipefail

PEON_DIR="${CLAUDE_PEON_DIR:-$HOME/.claude/hooks/simple-peon-ping}"
SOUNDS="$PEON_DIR/sounds"
VOLUME="${CLAUDE_PEON_VOLUME:-0.8}"  # 0.0–1.0

# Pick a random WAV from a category subdirectory
pick_from() {
  local files=("$SOUNDS/$1"/*.wav)
  [[ -e "${files[0]}" ]] || return 1
  printf '%s' "${files[$((RANDOM % ${#files[@]}))]}"
}

# Play a file using whatever audio tool is available
play() {
  local file="$1"
  [[ -f "$file" ]] || return
  if command -v afplay &>/dev/null; then
    afplay -v "$VOLUME" "$file" &
  elif command -v paplay &>/dev/null; then
    paplay --volume="$(awk "BEGIN{printf \"%d\", $VOLUME * 65536}")" "$file" &
  elif command -v aplay &>/dev/null; then
    aplay -q "$file" &
  elif command -v powershell.exe &>/dev/null; then
    local winpath
    winpath=$(wslpath -w "$file" 2>/dev/null) || return
    winpath="${winpath//\'/\'\'}"  # escape single quotes for PowerShell string
    powershell.exe -c "(New-Object Media.SoundPlayer '$winpath').PlaySync()" &
  fi
}

# Parse hook event from stdin
INPUT=$(cat)
EVENT=$(printf '%s' "$INPUT" | jq -r '.hook_event_name // empty')
NTYPE=$(printf '%s' "$INPUT" | jq -r '.notification_type // empty')

case "$EVENT" in
  SessionStart)        play "$(pick_from greeting)" ;;
  UserPromptSubmit)    play "$(pick_from acknowledge)" ;;
  PostToolUseFailure)  play "$(pick_from error)" ;;
  PreCompact)          play "$(pick_from compact)" ;;
  Notification)
    case "$NTYPE" in
      permission_prompt) play "$(pick_from permission)" ;;
      idle_prompt)       play "$(pick_from complete)" ;;
    esac ;;
esac

wait
exit 0

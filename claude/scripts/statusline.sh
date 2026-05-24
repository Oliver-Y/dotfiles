#!/usr/bin/env bash
# Claude Code statusLine handler — receives JSON on stdin, writes to a temp file
# that the tmux custom plugin reads.
STATUSFILE="/tmp/claude-statusline-$(whoami).txt"
INPUT=$(cat)
PCT=$(echo "$INPUT" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
MODEL=$(echo "$INPUT" | jq -r '.model.display_name // empty' 2>/dev/null)
if [ -n "$PCT" ]; then
  printf '%s %.0f%%' "${MODEL:-Claude}" "$PCT" > "$STATUSFILE"
else
  printf '%s --%%' "${MODEL:-Claude}" > "$STATUSFILE"
fi

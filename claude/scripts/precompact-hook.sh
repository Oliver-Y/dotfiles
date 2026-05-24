#!/usr/bin/env bash
set -e
# PreCompact hook — injects additionalContext into the compaction summary.
# This is the real lever for controlling what survives compaction.
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreCompact",
    "additionalContext": "PRESERVE during compaction: (1) full list of modified files and their paths, (2) failing test names and error messages, (3) current branch name and task context, (4) any active plan or task list, (5) which CLAUDE.md rules have been applied in this session."
  }
}
EOF

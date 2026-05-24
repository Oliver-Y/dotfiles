#!/usr/bin/env bash
# Nightly perf report generator -- launched by crontab at 5:03am
# Posts to #oliver-nightly-perf-report (C0AMEFW6KJS)
#
# Usage: manually run with ./nightly_perf_report.sh
# Or via crontab: 3 5 * * * /home/oliver/.claude/scripts/nightly_perf_report.sh
#
# Logs to ~/.claude/scripts/nightly_perf_report.log

set -euo pipefail

LOGFILE="/home/oliver/.claude/scripts/nightly_perf_report.log"
WORKDIR="/home/oliver/core-stack"
CLAUDE="/home/oliver/.local/bin/claude"

echo "=== Nightly perf report started at $(date) ===" >> "$LOGFILE"

cd "$WORKDIR"

"$CLAUDE" -p \
  --model opus \
  --permission-mode auto \
  --max-budget-usd 5.00 \
  --allowedTools "Agent Bash Read Glob Grep mcp__claude_ai_Slack__slack_read_channel mcp__claude_ai_Slack__slack_read_thread mcp__claude_ai_Slack__slack_search_public mcp__claude_ai_Slack__slack_search_channels mcp__claude_ai_Slack__slack_send_message mcp__claude_ai_Atlassian__getConfluencePage mcp__claude_ai_Atlassian__searchConfluenceUsingCql WebFetch" \
  "$(cat <<'PROMPT'
Generate the nightly perf report and post it to #oliver-nightly-perf-report (C0AMEFW6KJS).

**Section A: Embedded BK Validation**
- Read #stack-embedded-buildkite (C08HQFN2M7V) for the most recent master branch run (nightly runs land between 2-5am PT)
- Pick the latest master build on the mce108 scenario, read the thread for per-component latency, inter-component, accumulated time, FPS, contention, telegraf data
- Summarize: full-stack latency (p50/p95/p99), FPS, planner health, perception health, drops
- Top 3-5 findings (regressions, anomalies, bottlenecks vs prior runs)
- Include buildkite build link and slack thread link

**Section B: Vehicle Master Test**
- Read #eng-sds-automotive-testing (C07M367JRV5) for the most recent "SDS Daily Master Testing" thread
- Find the Confluence report link, extract the drive_id
- If a new vehicle test exists since the last report, summarize: vehicle, route, duration, branch, drive_id, data explorer link
- If no new vehicle test, note "No new vehicle test since <last date>"

**Cross-Section:** Compare BK vs vehicle findings if both are available. Identify systemic patterns.

**Format:** Use this structure exactly:
_Nightly Perf Report -- YYYY-MM-DD_
-------------------------
_A: Embedded BK Validation_ (bag looper CI)
<buildkite link> | <slack thread link>
Branch: master | Rig: <rig> | Scenario: <scenario>
- Full-stack: p50=Xms p95=Xms p99=Xms @ X Hz
- Planner: X% healthy | Perception: healthy/unhealthy
- GPU contention: X.Xx | Drops: N
_Findings:_
1. ...
2. ...
3. ...
-------------------------
_B: Vehicle Master Test_ (or "No new vehicle test")
...
-------------------------
_Cross-Section:_
...
_Action Items:_
1. ...

**IMPORTANT:**
- First check #oliver-nightly-perf-report to see the last posted report. If the latest master embedded BK build number is the same as the last report, do NOT post a duplicate -- just exit.
- Post as a single message (not threaded).
- Do not use emojis except :rotating_light: for critical findings.
- Keep it concise -- the reader will be on a train.
PROMPT
)" >> "$LOGFILE" 2>&1

echo "=== Nightly perf report finished at $(date) ===" >> "$LOGFILE"

#!/bin/bash
# Read-only: find which Hermes component asks for the "nous" (cloud) provider by default.
cd "$HOME/.hermes/hermes-agent" || exit 1
echo "=== explicit nous defaults in code ==="
grep -rnE "[\"']nous[\"']" --include=*.py agent hermes_cli gateway tools 2>/dev/null | grep -v -i test | grep -iE 'default|provider|=' | head -30
echo "=== log lines just before the first nous warning ==="
grep -n "nous requested" "$HOME/.hermes/logs/agent.log" | head -2
L=$(grep -n "nous requested" "$HOME/.hermes/logs/agent.log" | head -1 | cut -d: -f1)
[ -n "$L" ] && sed -n "$((L-8)),$((L))p" "$HOME/.hermes/logs/agent.log" | cut -c1-250

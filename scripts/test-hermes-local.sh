#!/bin/bash
# Ask Hermes one question via the CLI while recording every network connection it opens.
export PATH="$HOME/.local/bin:$PATH"
LOG=$(mktemp)
( while true; do ss -tnpH state established 2>/dev/null; sleep 0.3; done ) > "$LOG" &
WATCH=$!
START=$(date +%s)
echo "=== Hermes answer ==="
hermes chat -Q -q "In one sentence: what are you, and which model are you running on?" 2>&1 | tail -15
echo "=== took $(( $(date +%s) - START ))s ==="
kill $WATCH 2>/dev/null
echo "=== remote addresses opened by any process during the test ==="
awk '{print $4, $6}' "$LOG" | sed -E 's/users:\(\("([^"]+)".*/\1/' | sort -u
rm -f "$LOG"
echo "=== hermes status ==="
hermes status 2>&1 | head -40

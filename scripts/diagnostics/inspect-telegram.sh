#!/bin/bash
# Read-only: find Telegram env var names and how the Hermes gateway runs.
export PATH="$HOME/.local/bin:$PATH"
R="$HOME/.hermes/hermes-agent"
echo "=== Telegram env vars referenced in code ==="
grep -rhoE 'TELEGRAM_[A-Z_]+' "$R/gateway" "$R/hermes_cli" --include=*.py 2>/dev/null | sort | uniq -c | sort -rn | head -20
echo "=== gateway help ==="
hermes gateway --help 2>&1 | head -40
echo "=== how is the gateway running now? ==="
systemctl --user list-units --all 2>/dev/null | grep -i hermes
systemctl list-units --all 2>/dev/null | grep -i hermes
ps -eo pid,etime,args | grep -i 'hermes' | grep -v grep | cut -c1-160

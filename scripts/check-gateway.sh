#!/bin/bash
# Read-only: confirm the gateway service is running and connected to Telegram.
export PATH="$HOME/.local/bin:$PATH"
systemctl list-units --all --no-pager | grep -i hermes
UNIT=$(systemctl list-units --all --no-pager --plain | grep -io 'hermes[^ ]*\.service' | head -1)
echo "unit: $UNIT | enabled: $(systemctl is-enabled "$UNIT" 2>&1) | active: $(systemctl is-active "$UNIT" 2>&1)"
hermes gateway status 2>&1 | head -6
echo "=== gateway log (telegram) ==="
grep -iE 'telegram|platform|allow|error' "$HOME/.hermes/logs/gateway.log" | tail -12 | cut -c1-200
echo "=== outbound connections now ==="
ss -tnpH state established 2>/dev/null | awk '{print $4}' | sed -E 's/:[0-9]+$//' | sort | uniq -c

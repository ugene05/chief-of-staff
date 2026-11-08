#!/bin/bash
# Read-only: identify the one wget connection seen during the network audit.
LOG=/var/log/cos-netlog.txt
echo "=== when ==="
awk '/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]$/{t=$0} /wget/{print t, $0}' $LOG | cut -c1-200
T=$(awk '/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]$/{t=$0} /wget/{print t; exit}' $LOG)
echo "=== system journal around $T ==="
journalctl --since "today $T" --until "today $T" -o short --no-pager 2>/dev/null | head -5
journalctl -S "$(date -d "today $T -20 sec" '+%F %T')" -U "$(date -d "today $T +20 sec" '+%F %T')" --no-pager | cut -c1-200 | head -30
echo "=== reverse DNS ==="
getent hosts 34.253.181.30 || echo "(no reverse name)"
echo "=== what in Hermes uses wget? ==="
grep -rln 'wget' /home/ugene05/.hermes/hermes-agent --include=*.py --include=*.sh 2>/dev/null | grep -v test | head
echo "=== Hermes logs around that time ==="
grep -h "$(echo $T | cut -c1-5)" /home/ugene05/.hermes/logs/agent.log /home/ugene05/.hermes/logs/gateway.log 2>/dev/null | cut -c1-200 | head -20
echo "=== the empty message at 00:08 (voice note / photo?) ==="
grep -E '00:08:1[0-9]' /home/ugene05/.hermes/logs/gateway.log /home/ugene05/.hermes/logs/agent.log | cut -c1-220 | head -10

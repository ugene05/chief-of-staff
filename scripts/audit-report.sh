#!/bin/bash
# Zero-cloud audit, part 2 (read-only): summarise the 15-minute connection log
# and the Telegram messages handled during it.
LOG=/var/log/cos-netlog.txt
echo "=== log status ==="
echo "first sample: $(grep -m1 -E '^[0-9]{2}:[0-9]{2}:[0-9]{2}$' $LOG)  last sample: $(grep -E '^[0-9]{2}:[0-9]{2}:[0-9]{2}$' $LOG | tail -1)  finished: $(grep -c AUDIT-END $LOG)"
echo "=== every outside address seen, with the program (127.x and Linux-internal excluded) ==="
grep -vE '^[0-9]{2}:[0-9]{2}:[0-9]{2}$|AUDIT-END' $LOG \
 | awk '{peer=$6; prog=$7; sub(/:[0-9]+$/,"",peer); sub(/^users:\(\("/,"",prog); sub(/".*/,"",prog); print $1, peer, prog}' \
 | grep -vE ' (127\.|\[::1\]|\[::ffff:127\.|0\.0\.0\.0|\*)' | sort | uniq -c | sort -rn
echo "=== DNS server Linux uses ==="
grep nameserver /etc/resolv.conf
echo "=== Telegram messages handled during the audit ==="
grep -E 'inbound message: platform=telegram' /home/ugene05/.hermes/logs/gateway.log | tail -10 | sed -E 's/.*(..:..:..),[0-9]+ .*user=([^ ]+).*msg=(.{0,50}).*/\1 user=\2 msg=\3/'
echo "=== messages from anyone NOT allowed ==="
grep -iE 'unauthori[sz]ed|not allowed|denied|ignoring message|not in allowlist' /home/ugene05/.hermes/logs/gateway.log | tail -5 | cut -c1-200
echo "=== model calls during the audit went to ==="
grep -oE 'base_url=[^ ]+|provider=[a-z-]+' /home/ugene05/.hermes/logs/agent.log | tail -200 | sort | uniq -c

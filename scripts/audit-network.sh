#!/bin/bash
# Zero-cloud audit, part 1 (run with sudo):
#  - turn off Telegram's DNS-over-HTTPS fallback lookups (Google/Cloudflare)
#  - refresh and restart the Hermes gateway service
#  - record every network connection Linux makes for 15 minutes
set -e
U=ugene05
H=/home/$U
ENV=$H/.hermes/.env
LOG=/var/log/cos-netlog.txt

# 1. No DoH lookups to Google/Cloudflare
if grep -q '^HERMES_TELEGRAM_DISABLE_FALLBACK_IPS=' "$ENV"; then
  sed -i 's/^HERMES_TELEGRAM_DISABLE_FALLBACK_IPS=.*/HERMES_TELEGRAM_DISABLE_FALLBACK_IPS=1/' "$ENV"
else
  echo 'HERMES_TELEGRAM_DISABLE_FALLBACK_IPS=1' >> "$ENV"
fi
chown $U:$U "$ENV"; chmod 600 "$ENV"
echo "DoH fallback lookups: off"

# 2. Refresh + restart the gateway service
HOME=$H HERMES_HOME=$H/.hermes $H/.local/bin/hermes gateway restart --system
sleep 10
systemctl is-active hermes-gateway

# 3. 15-minute connection log (TCP + UDP, with the program name)
systemctl stop cos-netlog 2>/dev/null || true
: > "$LOG"
systemd-run --unit=cos-netlog --description="Chief of Staff 15-min network audit" \
  bash -c "end=\$((SECONDS+900)); while [ \$SECONDS -lt \$end ]; do date '+%H:%M:%S' >> $LOG; ss -tunpH >> $LOG; sleep 1; done; echo AUDIT-END >> $LOG"
echo "Connection log running for 15 minutes -> $LOG"
echo "AUDIT STARTED"

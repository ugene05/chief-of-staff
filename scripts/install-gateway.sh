#!/bin/bash
# Install the Hermes gateway (Telegram) as a system service that starts whenever Linux starts.
# Run with sudo.
set -e
U=ugene05
H=/home/$U
HERMES=$H/.local/bin/hermes
# stop the temporary on-demand gateway
sudo -u $U HERMES_HOME=$H/.hermes $HERMES gateway stop 2>/dev/null || true
pkill -u $U -f 'hermes_cli.main .*gateway run' 2>/dev/null || true
sleep 2
HOME=$H HERMES_HOME=$H/.hermes $HERMES gateway install --system --run-as-user $U --start-now --start-on-login
sleep 8
echo "=== service status ==="
systemctl list-units --all | grep -i hermes || true
sudo -u $U HERMES_HOME=$H/.hermes $HERMES gateway status 2>&1 | head -10
echo "GATEWAY DONE"

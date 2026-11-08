#!/bin/bash
# Read-only: show how Hermes responds to messages from users not on the allowlist.
F=/home/ugene05/.hermes/hermes-agent/gateway/run_inbound.py
sed -n '95,145p' "$F"
echo "-----"
sed -n '220,250p' "$F"
echo "=== unauthorized_dm_behavior setting ==="
grep -n -iE 'unauthori[sz]ed_dm|dm_behavio|decline' /home/ugene05/.hermes/config.yaml | head -8

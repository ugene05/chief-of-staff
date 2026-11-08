#!/bin/bash
# Read-only: show Hermes config, which secrets are set (names only), and docs available.
H="$HOME/.hermes"
ls -la "$H"
echo "===CONFIG==="
cat "$H/config.yaml"
echo "===ENV (names only)==="
[ -f "$H/.env" ] && sed -E 's/=.*/=<hidden>/' "$H/.env" | grep -v '^#' | grep -v '^$'
echo "===DOCS==="
find "$H/hermes-agent" -path '*/node_modules' -prune -o -name '*.md' -print 2>/dev/null | grep -iE 'local-model|provider|telegram|security|tools|cua|computer|telemetry|privacy' | head -40

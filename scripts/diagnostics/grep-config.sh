#!/bin/bash
# Read-only: find the documented keys for local models, context length, auxiliary models and disabled toolsets.
C="$HOME/.hermes/config.yaml"
R="$HOME/.hermes/hermes-agent"
echo "=== context_length / api_key / custom in config template ==="
grep -n -iE 'context_length|api_key|provider: *"?custom|localhost|127\.0\.0\.1|11434' "$C" | head -30
echo "=== auxiliary section ==="
awk '/^#? *auxiliary:/{p=1} p{print NR": "$0; n++} n>70{exit}' "$C"
echo "=== disabled_toolsets / tool_search ==="
grep -n -iE 'disabled_toolsets|tool_search|defer' "$C" | head -15
echo "=== providers README (local) ==="
grep -n -iE -B2 -A8 'ollama' "$R/providers/README.md" | head -60
echo "=== local-models doc ==="
find "$R" -path '*/node_modules' -prune -o -iname '*local-model*' -print 2>/dev/null | head

#!/bin/bash
# Read-only: pull the parts of Hermes docs/code we need for a local-only, locked-down setup.
R="$HOME/.hermes/hermes-agent"
echo "=== providers-and-models.md (ollama/local/custom/auxiliary) ==="
grep -n -iE -A3 'ollama|custom|base_url|auxiliary|local' "$R/skills/autonomous-ai-agents/hermes-agent/references/providers-and-models.md" | head -120
echo "=== security-privacy.md ==="
sed -n 1,200p "$R/skills/autonomous-ai-agents/hermes-agent/references/security-privacy.md"
echo "=== toolset definitions: hermes-telegram ==="
grep -rn -E '"hermes-telegram"|hermes-telegram' "$R" --include=*.py 2>/dev/null | grep -v test | head -10

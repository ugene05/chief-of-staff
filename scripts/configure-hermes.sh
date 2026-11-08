#!/bin/bash
# Configure Hermes for the Chief of Staff project: local model only, minimal tools.
# Safe to re-run. No secrets in this file.
set -e
export PATH="$HOME/.local/bin:$PATH"
cp "$HOME/.hermes/config.yaml" "$HOME/.hermes/config.yaml.bak-$(date +%Y%m%d-%H%M%S)"

LOCAL=http://127.0.0.1:11434/v1
MODEL=qwen3:8b

# Main model: local Ollama only
hermes config set model.provider custom
hermes config set model.base_url "$LOCAL"
hermes config set model.default "$MODEL"
hermes config set model.context_length 16384
hermes config set model.ollama_num_ctx 16384

# Helper models: explicitly local (the rest default to the main model)
for task in compression session_search; do
  hermes config set "auxiliary.$task.provider" custom
  hermes config set "auxiliary.$task.base_url" "$LOCAL"
  hermes config set "auxiliary.$task.model" "$MODEL"
done
hermes config set auxiliary.title_generation.enabled false

# Minimal tools for Stage 1: no terminal, files, web, browser, computer use, TTS
hermes config set platform_toolsets.telegram '[memory, todo, clarify, session_search]'
hermes config set platform_toolsets.cli '[memory, todo, clarify, session_search]'

# Privacy and safety
hermes config set telemetry.shared_metrics.enabled false
hermes config set telemetry.shared_metrics.send false
hermes config set auth.adopt_external_logins false
hermes config set security.redact_secrets true
hermes config set updates.pre_update_backup true

echo "=== resulting settings ==="
for k in model.provider model.base_url model.default model.context_length model.ollama_num_ctx \
         auxiliary.compression.provider auxiliary.session_search.provider auxiliary.title_generation.enabled \
         platform_toolsets.telegram platform_toolsets.cli telemetry.shared_metrics.enabled \
         auth.adopt_external_logins updates.pre_update_backup; do
  echo "$k = $(hermes config get "$k" 2>&1 | tr '\n' ' ')"
done
echo "=== cloud API keys present in .env (names only, should be none) ==="
grep -E '^[A-Z_]*(API_KEY|TOKEN|SECRET)[A-Z_]*=.+' "$HOME/.hermes/.env" | sed -E 's/=.*/=<set>/' || echo "none"
echo "CONFIG DONE"

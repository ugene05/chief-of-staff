#!/bin/bash
# Raise Ollama's context window to 64k (Hermes minimum) and download qwen3.5:4b. Run with sudo.
set -e
cat > /etc/systemd/system/ollama.service.d/override.conf <<'EOF'
[Service]
# Never use ollama.com cloud models (zero-cloud rule)
Environment=OLLAMA_NO_CLOUD=1
# Save graphics memory so a large context fits in 8GB
Environment=OLLAMA_FLASH_ATTENTION=1
Environment=OLLAMA_KV_CACHE_TYPE=q8_0
# Hermes Agent requires at least 64k context
Environment=OLLAMA_CONTEXT_LENGTH=65536
EOF
systemctl daemon-reload
systemctl restart ollama
sleep 3
echo "Settings applied. Downloading qwen3.5:4b (about 3.3GB)..."
ollama pull qwen3.5:4b
echo "ALL DONE"

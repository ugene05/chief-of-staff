#!/bin/bash
# Configure Ollama for the Chief of Staff project, then download the first model.
set -e
mkdir -p /etc/systemd/system/ollama.service.d
cat > /etc/systemd/system/ollama.service.d/override.conf <<'EOF'
[Service]
# Never use ollama.com cloud models (zero-cloud rule)
Environment=OLLAMA_NO_CLOUD=1
# Save graphics memory so a 16k context fits in 8GB
Environment=OLLAMA_FLASH_ATTENTION=1
Environment=OLLAMA_KV_CACHE_TYPE=q8_0
Environment=OLLAMA_CONTEXT_LENGTH=16384
EOF
systemctl daemon-reload
systemctl restart ollama
sleep 3
echo "Settings applied. Downloading qwen3:8b (about 5GB)..."
ollama pull qwen3:8b
echo "ALL DONE"

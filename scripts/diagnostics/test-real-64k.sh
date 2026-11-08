#!/bin/bash
# Load qwen3:8b with a REAL 64k window directly in Ollama and measure GPU fit and speed.
ollama stop qwen3:8b 2>/dev/null; sleep 2
for KV in q8_0; do
  echo "=== 64k window, KV cache $KV (server setting) ==="
  START=$(date +%s)
  curl -s localhost:11434/api/generate -d '{"model":"qwen3:8b","prompt":"Name three things a family should check before an overseas trip. Be brief.","stream":false,"think":false,"options":{"num_ctx":65536}}' \
    | python3 -c 'import sys,json; r=json.load(sys.stdin); print("tokens/sec:", round(r["eval_count"]/r["eval_duration"]*1e9,1), "| load s:", round(r["load_duration"]/1e9,1))'
  echo "wall: $(( $(date +%s) - START ))s"
  ollama ps
  nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader
done
echo "=== WSL memory visible ==="
free -g | head -2
ollama stop qwen3:8b

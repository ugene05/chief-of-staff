#!/bin/bash
# Try qwen3:8b with a 64k window: does Hermes accept it, how much fits on the GPU, how fast is it.
export PATH="$HOME/.local/bin:$PATH"
hermes config set model.context_length 65536 >/dev/null
hermes config set model.ollama_num_ctx 65536 >/dev/null
ollama stop qwen3:8b 2>/dev/null
LOG=$(mktemp)
( while true; do ss -tnpH state established 2>/dev/null; sleep 0.3; done ) > "$LOG" &
WATCH=$!
START=$(date +%s)
echo "=== Hermes answer ==="
hermes chat -Q -q "In one sentence: what are you, and which model are you running on?" 2>&1 | tail -8
echo "=== took $(( $(date +%s) - START ))s (includes loading the model) ==="
START=$(date +%s)
echo "=== second question (model already loaded) ==="
hermes chat -Q -q "Name three things a family should check before an overseas trip. Be brief." 2>&1 | tail -10
echo "=== took $(( $(date +%s) - START ))s ==="
kill $WATCH 2>/dev/null
echo "=== remote addresses opened during the test ==="
awk '{print $4}' "$LOG" | sort -u
rm -f "$LOG"
echo "=== how the model is loaded ==="
ollama ps
nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader
free -g | head -2
echo "=== prompt size Hermes sent (from Ollama log) ==="
journalctl -u ollama --since "-5 min" --no-pager 2>/dev/null | grep -oE 'prompt_tokens=[0-9]+|n_prompt_tokens=[0-9]+|"prompt_eval_count":[0-9]+|task.n_tokens=[0-9]+' | tail -5

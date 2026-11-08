#!/bin/bash
# Point Hermes at qwen3.5:4b with a real 64k window, then test speed, GPU fit and network connections.
export PATH="$HOME/.local/bin:$PATH"
MODEL=qwen3.5:4b
echo "=== Ollama check ==="
systemctl show ollama -p Environment | grep -oE 'OLLAMA_(NO_CLOUD|CONTEXT_LENGTH)=[0-9]+'
ollama list
hermes config set model.default "$MODEL" >/dev/null
hermes config set model.context_length 65536 >/dev/null
hermes config set model.ollama_num_ctx 65536 >/dev/null
hermes config set auxiliary.compression.model "$MODEL" >/dev/null
# remove the unrecognised session_search keys added earlier (falls back to the main model)
python3 - <<'PY'
import re, pathlib
p = pathlib.Path.home() / ".hermes/config.yaml"
t = p.read_text()
t2 = re.sub(r"\n  session_search:\n(    [^\n]*\n)+", "\n", t, count=1) if "\n  session_search:\n    provider: custom" in t else t
p.write_text(t2); print("session_search keys removed" if t2 != t else "session_search keys: nothing to remove")
PY
for k in model.default model.context_length model.ollama_num_ctx auxiliary.compression.model; do
  echo "$k = $(hermes config get "$k" 2>&1 | tr '\n' ' ')"
done
ollama stop qwen3:8b 2>/dev/null
LOG=$(mktemp)
( while true; do ss -tnpH state established 2>/dev/null; sleep 0.3; done ) > "$LOG" &
WATCH=$!
for Q in "In one sentence: what are you, and which model are you running on?" \
         "Name three things a family should check before an overseas trip. Be brief." \
         "Remember this: my preferred airline is Singapore Airlines. Then confirm in one sentence."; do
  START=$(date +%s)
  echo "=== Q: $Q"
  hermes chat -Q -q "$Q" 2>&1 | grep -v '^session_id' | sed '/^$/d' | tail -8
  echo "--- took $(( $(date +%s) - START ))s"
done
kill $WATCH 2>/dev/null
echo "=== remote addresses opened during the test (should all be 127.0.0.1) ==="
awk '{print $4}' "$LOG" | sed -E 's/:[0-9]+$//' | sort | uniq -c
rm -f "$LOG"
echo "=== GPU fit ==="
ollama ps
nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader
echo "=== Hermes memory file ==="
cat "$HOME/.hermes/memories/USER.md" "$HOME/.hermes/memories/MEMORY.md" 2>/dev/null
echo "=== errors in the last few minutes ==="
awk -v d="$(date -d '-5 min' '+%Y-%m-%d %H:%M')" '$0 >= d' "$HOME/.hermes/logs/errors.log" | cut -c1-220 | tail -8

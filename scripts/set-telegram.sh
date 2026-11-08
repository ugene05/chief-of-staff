#!/bin/bash
# Save the Telegram bot token (typed hidden) and lock the bot to the owner's Telegram ID.
# The token is never printed, never passed on a command line, never sent anywhere except Telegram.
set -e
ENV="$HOME/.hermes/.env"
OWNER_ID=225020706

echo "Paste your bot token from @BotFather, then press Enter."
echo "(Nothing will show while you paste. That is normal.)"
read -rs TOKEN
echo
if ! [[ "$TOKEN" =~ ^[0-9]{6,12}:[A-Za-z0-9_-]{30,}$ ]]; then
  echo "That doesn't look like a bot token (expected digits:letters). Nothing was saved. Run me again."
  exit 1
fi

# Ask Telegram who this bot is (the only place the token goes)
INFO=$(curl -s --max-time 15 "https://api.telegram.org/bot${TOKEN}/getMe")
if ! echo "$INFO" | grep -q '"ok":true'; then
  echo "Telegram rejected that token. Nothing was saved. Check it in BotFather and run me again."
  exit 1
fi
BOTNAME=$(echo "$INFO" | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["username"])')

# Write/replace the settings in .env without echoing the token
python3 - "$ENV" "$TOKEN" "$OWNER_ID" <<'PY'
import sys, re, pathlib
path, token, owner = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
text = path.read_text() if path.exists() else ""
def put(t, k, v):
    line = f"{k}={v}"
    return re.sub(rf"^#?\s*{k}=.*$", line, t, flags=re.M) if re.search(rf"^#?\s*{k}=", t, flags=re.M) else t.rstrip("\n") + "\n" + line + "\n"
text = put(text, "TELEGRAM_BOT_TOKEN", token)
text = put(text, "TELEGRAM_ALLOWED_USERS", owner)
# make sure nothing opens the bot to everyone
text = re.sub(r"^(GATEWAY_ALLOW_ALL_USERS=.*)$", r"# disabled: \1", text, flags=re.M)
path.write_text(text)
PY
chmod 600 "$ENV"
unset TOKEN INFO

echo "Saved. Your bot is @${BOTNAME}, locked to Telegram ID ${OWNER_ID}."
echo "TELEGRAM DONE"

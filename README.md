# Chief of Staff — how to run, check and fix it

Your private assistant, **Hermes**, runs on this PC and talks to you on Telegram. Everything about the design is in [SPEC.md](SPEC.md). Every installed program, its version and how to update it is in [VERSIONS.md](VERSIONS.md).

Commands below go in a **PowerShell** window unless they say "inside Linux". Commands with `sudo` will ask for your **Linux password** (it's in Apple Passwords as "WSL Ubuntu (F:)").

---

## What runs where

| Piece | Where | Starts how |
|---|---|---|
| Ubuntu Linux (WSL) | `F:\WSL\Ubuntu\ext4.vhdx` | Windows task **"Chief of Staff - Keep Linux running"** at logon |
| Ollama (the AI model server) | inside Linux | Linux service `ollama`, starts with Linux |
| Model: qwen3.5:4b | inside Linux (on F:) | Loaded by Ollama on first message; unloads after 5 idle minutes |
| Hermes (the assistant) | inside Linux, `~/.hermes` | Linux service `hermes-gateway`, starts with Linux |
| Telegram bot | Telegram's servers | Hermes connects to it; only answers your ID 225020706 |
| This folder (the "brain") | `F:\chief-of-staff` | Plain files; open it in Obsidian as a vault |

**The chain:** you log in to Windows → the task starts Linux → Linux starts Ollama and Hermes → Hermes connects to Telegram.

---

## Is it working?

The quick way: send your bot a message on Telegram. The first reply after a quiet spell can take up to a minute while the model loads; after that, a few seconds.

The full check:
```
wsl -d Ubuntu-24.04 -- bash /mnt/f/chief-of-staff/scripts/check-gateway.sh
```
You want to see `active` and `telegram connected`, and only `149.154.x.x` (Telegram) under connections.

---

## Fixes

**The bot doesn't reply**
1. Is the PC awake and are you logged in? The bot only runs after you log in to Windows.
2. Restart Hermes:
   ```
   wsl -d Ubuntu-24.04 -- sudo systemctl restart hermes-gateway
   ```
3. Still nothing? Restart Linux completely, then start the keep-alive task again:
   ```
   wsl --shutdown
   ```
   ```
   Start-ScheduledTask -TaskPath "\ChiefOfStaff\" -TaskName "Chief of Staff - Keep Linux running"
   ```
4. Look at the error log:
   ```
   wsl -d Ubuntu-24.04 -- tail -30 /home/ugene05/.hermes/logs/errors.log
   ```

**Replies are very slow** — the model may be spilling out of the graphics card. Check:
```
wsl -d Ubuntu-24.04 -- ollama ps
```
`PROCESSOR` should say `100% GPU`. If not, close games or other GPU-heavy apps.

**After a Windows restart** — just log in. The task starts Linux and the bot within a minute.

---

## Rules for using the bot

- **Don't use these bot commands**, unless we've agreed to: `/yolo` (skips safety prompts), `/tools` (can switch on shell, web or computer control), `/model` and `/provider` (can point Hermes at a cloud model), `/update` (updates go through the monthly check; see SPEC section 8).
- **Never log Hermes into a cloud service** (`hermes auth`, `hermes portal`, `hermes model` with a cloud provider). The setup has no cloud logins on purpose.
- **Never paste secrets into Telegram or Claude.** Tokens go into Linux through `scripts/set-telegram.sh`, which hides what you type.

---

## Memory: Hermes's vs this folder

- **Hermes's own memory** is two tiny files inside Linux (`~/.hermes/memories/MEMORY.md` and `USER.md`, about 2,000 + 1,400 characters). It's what Hermes sees in every chat.
- **This folder's `memory/`** is the **source of truth** and the long-term record (`preferences.md`, `people.md`, `corrections.md`, `decisions.md`, `daily/`).
- Stage 1 finding: Hermes can't simply be pointed at `memory/` (its memory format and size limits are its own), so a **sync step** is needed. It's built with the nightly consolidation in Stage 4. Until then, important facts are copied here by hand.
- `memory/` and `logs/` **never go to GitHub** (`.gitignore`).

---

## Scripts (`scripts/`)

| Script | What it does | Run with |
|---|---|---|
| `check-gateway.sh` | Is Hermes running and connected to Telegram? | `wsl -d Ubuntu-24.04 -- bash /mnt/f/chief-of-staff/scripts/check-gateway.sh` |
| `versions.sh` | Prints all versions (for VERSIONS.md) | `wsl -d Ubuntu-24.04 -- bash /mnt/f/chief-of-staff/scripts/versions.sh` |
| `audit-readonly.sh` | Checks for cloud logins, fallbacks and risky settings | `wsl -d Ubuntu-24.04 -- bash /mnt/f/chief-of-staff/scripts/audit-readonly.sh` |
| `test-hermes-local.sh` | Asks Hermes a question and records every network connection | `wsl -d Ubuntu-24.04 -- bash /mnt/f/chief-of-staff/scripts/test-hermes-local.sh` |
| `configure-hermes.sh` | Re-applies the local-only, minimal-tools settings | `wsl -d Ubuntu-24.04 -- bash /mnt/f/chief-of-staff/scripts/configure-hermes.sh` |
| `set-model.sh` | Switches Hermes to qwen3.5:4b at 64k and tests it | `wsl -d Ubuntu-24.04 -- bash /mnt/f/chief-of-staff/scripts/set-model.sh` |
| `ollama-64k.sh` | Ollama settings (no cloud, 64k) + model download | `wsl -d Ubuntu-24.04 -- sudo bash /mnt/f/chief-of-staff/scripts/ollama-64k.sh` |
| `set-telegram.sh` | Enter/replace the bot token (hidden) and lock to your ID | `wsl -d Ubuntu-24.04 -- bash /mnt/f/chief-of-staff/scripts/set-telegram.sh` |
| `install-gateway.sh` | (Re)installs Hermes as a Linux service | `wsl -d Ubuntu-24.04 -- sudo bash /mnt/f/chief-of-staff/scripts/install-gateway.sh` |
| `setup-keep-linux-running.ps1` | Creates the Windows logon task | `powershell -ExecutionPolicy Bypass -File F:\chief-of-staff\scripts\setup-keep-linux-running.ps1` |
| `diagnostics/` | One-off checks from the Stage 1 build, kept for reference | — |

---

## Backups

- **GitHub (private):** only `SPEC.md`, `README.md`, `VERSIONS.md`, `agents/`, `rules/`, `skills/`, `evals/`, `scripts/`. Before every push, check nothing private is staged: `git status` should never list `memory/`, `logs/` or any `.env`.
- **`memory/` and `logs/`:** weekly copy to the WD 4TB drive (D:), set up in Stage 4.
- **Linux itself** (`F:\WSL\Ubuntu\ext4.vhdx`): can be exported with `wsl --export Ubuntu-24.04 D:\backup\ubuntu.tar` if ever needed.

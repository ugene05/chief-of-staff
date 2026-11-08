# Installed software versions

Last checked: **2026-11-08** (Stage 1 install). Lives in the repo at `F:\chief-of-staff\VERSIONS.md`.
Regenerate the Linux part with: `wsl -d Ubuntu-24.04 -- bash /mnt/f/chief-of-staff/scripts/versions.sh`
How and when to update: SPEC.md section 8, "Monthly software check".

## Windows side
| Software | Version | Where | How to check / update |
|---|---|---|---|
| Windows 11 Home | 10.0.26200 | C: | Windows Update |
| NVIDIA driver | 610.88 | C: | NVIDIA App |
| WSL | 2.7.10.0 (kernel 6.18.33.2-2) | C: | `wsl --version` / `wsl --update` |
| Ollama (Windows copy) | 0.40.13 | C: | Not used by this project. Quit and removed from startup 2026-11-09 (shortcut kept in `F:\chief-of-staffackup\Ollama.lnk`; to restore, move it back to the Startup folder). Still installed. |
| Keep-alive task | `\ChiefOfStaff\Chief of Staff - Keep Linux running` (at logon: `wsl -d Ubuntu-24.04 --exec sleep infinity`, hidden, restarts every 1 min if it stops) | Task Scheduler | Created 2026-11-08 by `scripts/setup-keep-linux-running.ps1`. Without it, Windows shuts Linux down ~15s after the last window closes and the bot goes offline. Starts only after you log in. |
| Power plan | Balanced; sleep when plugged in: **Never** (set 2026-11-08); hibernate: never | Settings → System → Power & battery | |

## Linux side (Ubuntu in WSL2, stored at `F:\WSL\Ubuntu\ext4.vhdx`)
| Software | Version | How to check / update |
|---|---|---|
| Ubuntu | 24.04.5 LTS, all packages updated 2026-11-08 (93 updates, no reboot needed) | `sudo apt update && sudo apt upgrade` (security updates install automatically) |
| Ollama | 0.40.15 | `ollama --version` / re-run `curl -fsSL https://ollama.com/install.sh \| sh` |
| Ollama settings | `OLLAMA_NO_CLOUD=1`, `OLLAMA_FLASH_ATTENTION=1`, `OLLAMA_KV_CACHE_TYPE=q8_0`, `OLLAMA_CONTEXT_LENGTH=65536` (Hermes needs ≥64k) | `/etc/systemd/system/ollama.service.d/override.conf`. Re-check after every Ollama update. |
| **Daily model: qwen3.5:4b** (Stage 1 pick; Stage 2 decides the final one) | id `d8b0f5e9760c`, 3.3GB; 256k native context; at 64k uses 4.5GB, 100% GPU; 3–8s per short answer | `ollama list` / `ollama pull qwen3.5:4b` (a model change needs a Stage 2 re-test) |
| Model: qwen3:8b (not used) | id `500a1f067a9f`, 5.2GB. Max context 40k, below Hermes's 64k minimum. | Keep for Stage 2 comparison or remove with `ollama rm qwen3:8b` |
| Hermes Agent | v0.23.0 (2026.9.24), stable, commit `2bd378ed1b` | `hermes --version` / `hermes update` |
| Hermes Telegram gateway | systemd service `hermes-gateway` (system-level, enabled, runs as ugene05); bot locked to `TELEGRAM_ALLOWED_USERS=225020706`; token in `~/.hermes/.env` (mode 600) | `systemctl status hermes-gateway`; re-run `scripts/install-gateway.sh` with sudo |
| Hermes settings | provider `custom` at `http://127.0.0.1:11434/v1`, model qwen3.5:4b, context 65536; compression helper local; titles off; tools (Telegram + CLI): memory, todo, clarify, session_search; telemetry off; external logins off; pre-update backup on | `~/.hermes/config.yaml`; re-apply with `scripts/configure-hermes.sh` + `scripts/set-model.sh` |
| Hermes tools (bundled, updated by `hermes update`) | Python 3.14.9, Node 26.12.1, npm 12.0.2, uv 0.13.5, ripgrep 15.2.0, ffmpeg 9.0.1, cua-driver 0.21.0 | `ls ~/.hermes/tools` |
| git | 2.43.0 | apt |
| libatomic1 (needed by Node) | 14.2.0-4ubuntu2~24.04.1 | apt |
| zstd (needed by Ollama installer) | 1.5.5+dfsg2-2build1.1 | apt |

## Stage 1 status (2026-11-09 00:35 SGT)
- Done: WSL + GPU, Ollama (no cloud, 64k), Hermes local-only with minimal tools, Telegram both ways (owner-only), auto-start at logon, PC never sleeps, repo + private GitHub, README.
- Zero-cloud audit (15 min, 23:59–00:14): 27 model calls, all to 127.0.0.1; only outside connection Telegram (149.154.166.110), plus Ubuntu's daily motd-news fetch (motd.ubuntu.com, AWS). Telegram DNS-over-HTTPS lookups (Google/Cloudflare) turned off. Photos are read locally by the model.
- Strangers: `unauthorized_dm_behavior: ignore` set explicitly (already the default with an allowlist).
- Done 2026-11-09: Ubuntu motd-news off (timer disabled, `ENABLED=0`); Windows Ollama quit and removed from startup.
- **Still to do:** other-account test (stranger gets no reply; log shows "Unauthorized user (ignored)").
- Model note for Stage 2: qwen3.5:4b saved "passport expires March 2028" as a fact when asked as a question, and didn't remove it when corrected.

## Open items
- WSL only sees 15GB of the 32GB RAM (default limit). Raise it in `%UserProfile%\.wslconfig` before testing any ~30B model in Stage 2.
- Hermes logs a startup check for Nous Portal (cloud). It fails harmlessly because there is no login. Rule: never log Hermes into Nous Portal or any cloud provider.
- `cua-driver` (a computer-control tool) was installed by Hermes even with `--skip-browser`. It is **not usable**: the `computer_use` tool is not in Hermes's toolsets (only memory, todo, clarify, session_search). Keep it that way.

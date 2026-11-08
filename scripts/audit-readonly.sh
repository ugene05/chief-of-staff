#!/bin/bash
# Read-only checks: risky Telegram slash commands, DNS-over-HTTPS hosts, cloud logins.
export PATH="$HOME/.local/bin:$PATH"
R="$HOME/.hermes/hermes-agent"
echo "=== DoH / fallback hosts used by the Telegram plugin ==="
grep -rhoE 'https://[a-z0-9.-]+/(dns-query|resolve)[^"'"'"' ]*' "$R/plugins/platforms/telegram" 2>/dev/null | sort -u
grep -rhoE '"(dns\.google|cloudflare-dns\.com|1\.1\.1\.1|8\.8\.8\.8|mozilla\.cloudflare-dns\.com)[^"]*"' "$R/plugins/platforms/telegram" 2>/dev/null | sort -u
grep -rn -iE 'doh|dns_over_https|fallback_ips' "$R/plugins/platforms/telegram"/*.py 2>/dev/null | grep -iE 'config|enabled|env|extra' | head -8 | cut -c1-200
echo "=== Telegram slash commands that touch model/provider/tools/auth/yolo/shell ==="
grep -rhoE '"/?(model|provider|tools|toolsets|auth|login|portal|yolo|shell|terminal|exec|sh|update|fallback|moa|approve|config|set)"' "$R/gateway" "$R/hermes_cli/commands"* 2>/dev/null | sort -u | head -30
echo "=== cloud logins (should be none) ==="
hermes auth list 2>&1 | head -15
ls -la "$HOME/.hermes/auth.json" 2>&1
echo "=== fallback providers (should be none) ==="
hermes fallback list 2>&1 | head -8

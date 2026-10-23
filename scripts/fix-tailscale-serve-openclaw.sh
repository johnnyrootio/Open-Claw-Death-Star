#!/usr/bin/env bash
# Run on your Mac. SSHs to death-star and switches Tailscale serve so /openclaw/ is preserved.
# You will be prompted for your sudo password on death-star.
set -e
ssh -t death-star 'sudo tailscale serve --https=8443 off && sudo tailscale serve --bg --https=8443 http://127.0.0.1:18789'
echo ""
echo "Verifying..."
curl -sS -o /dev/null -w "HTTPS /openclaw/ → %{http_code}\n" -k "https://death-star.taile96045.ts.net:8443/openclaw/"

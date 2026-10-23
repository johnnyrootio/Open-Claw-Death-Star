# OpenClaw on Death Star — REMOVED

**Status (2026-10-22):** OpenClaw was **completely removed** from Death Star.

Removed on the host:

- Docker compose stack / `alpine/openclaw` image
- `~/openclaw-in-docker`, `~/.openclaw`
- Tailscale Serve on **HTTPS 8443** (OpenClaw dashboard)
- Related npx CLI cache

Removed on the Mac (cleanup):

- `~/.openclaw`
- LaunchAgent `com.user.deathstar-tunnel.plist` (localhost tunnel for OpenClaw)

**Do not** treat older dashboard URLs (`:18789`, `:8443/openclaw`) or gateway tokens in prior chat history as live.

---

## Current Death Star access

Use the LLM stack docs instead:

- [Death Star setup.md](Death%20Star%20setup.md) — Tailscale account, MagicDNS, Open WebUI, Ollama
- [llm-death-star](https://github.com/johnnyrootio/llm-death-star) → `death-star-reference.md`

| Item | Value |
|------|--------|
| **Tailscale account** | johnamaral1967@gmail.com |
| **MagicDNS** | death-star.taile96045.ts.net |
| **Open WebUI** | https://death-star.taile96045.ts.net |
| **LLM** | Ollama `qwen3:30b` (primary) |

---

## Historical (no longer installed)

Previously: OpenClaw gateway in Docker, Telegram `@johhnyroot_openclaw_bot`, models Ollama `qwen3:30b` + Anthropic Claude Haiku 4.5, dashboard via Tailscale Serve on port 8443. That install is gone; re-install only if you deliberately bring OpenClaw back.

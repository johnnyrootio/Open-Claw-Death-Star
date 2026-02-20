# Run OpenClaw (MoltBot, ClawdBot) Safely with Docker — Summary

**Source:** [Run OpenClaw (MoltBot, ClawdBot) Safely with Docker: A Practical Guide for Beginners](https://towardsdev.com/run-openclaw-moltbot-clawdbot-safely-with-docker-a-practical-guide-for-beginners-94112a9b57be)  
**Author:** Bill WANG · Towards Dev · Jan 30, 2026

---

## Overview

The post describes a **Docker-based setup** for [OpenClaw](https://github.com/openclaw-ai/openclaw) (formerly MoltBot / ClawdBot): a lightweight, self-hosted AI agent framework. Running it in Docker keeps the host safe and works across Windows, macOS, Linux, NAS, and Raspberry Pi.

---

## Why Docker?

- OpenClaw can read files, run commands, and automate tasks — so misconfiguration or bad behavior can affect the host.
- Docker provides a **sandbox**: the AI runs in a container, the host filesystem stays isolated, and you can remove or recreate the container anytime.

---

## Prerequisites

- **Docker** installed ([get Docker](https://docs.docker.com/get-started/introduction/get-docker-desktop/))
- **Bash v4+** (on macOS with default Bash 3: `brew install bash`)

---

## Setup Steps

1. **Clone the repo**
   ```bash
   git clone https://github.com/ozbillwang/openclaw-in-docker.git
   cd openclaw-in-docker
   ```

2. **Set the OpenClaw image**
   ```bash
   export OPENCLAW_IMAGE="alpine/openclaw:latest"
   ```
   If `latest` causes issues (e.g. no models), use:
   ```bash
   export OPENCLAW_IMAGE="alpine/openclaw:main"
   ```

3. **Run the setup script**
   ```bash
   ./docker-setup.sh
   ```
   The script will:
   - Pull the OpenClaw gateway image
   - Run an interactive onboarding wizard
   - Start the gateway via Docker Compose
   - Generate a gateway token and store it in `.env`

---

## Onboarding (during setup)

When prompted, use:

- **Gateway bind:** `lan`
- **Gateway auth:** `token`
- **Gateway token:** (script prints it; it’s also written to `.env`)
- **Tailscale exposure:** Off
- **Install Gateway daemon:** No

---

## Key Paths and Ports

| Item | Default |
|------|--------|
| Config directory | `~/.openclaw` |
| Workspace | `~/.openclaw/workspace` |
| Gateway port | 18789 |
| Bridge port | 18790 |

---

## Optional: Channels

After setup you can add:

- **WhatsApp (QR):** `docker compose -f docker-compose.yml run --rm openclaw-cli channels login`
- **Telegram:** `docker compose run --rm openclaw-cli channels add --channel telegram --token <token>`
- **Discord:** `docker compose run --rm openclaw-cli channels add --channel discord --token <token>`

Docs: [https://docs.openclaw.ai/channels](https://docs.openclaw.ai/channels)

---

## Environment / API keys

Copy `.env.example` to `.env` and set at least one model provider (and any channel tokens you use):

- `OPENCLAW_GATEWAY_TOKEN` — set by the setup script
- `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, `OPENROUTER_API_KEY`, etc.
- Channel: `TELEGRAM_BOT_TOKEN`, `DISCORD_BOT_TOKEN`, etc.

---

## Useful commands

- View gateway logs: `docker compose -f docker-compose.yml logs -f openclaw-gateway`
- Health check: `docker compose exec openclaw-gateway node dist/index.js health --token "<OPENCLAW_GATEWAY_TOKEN>"`

---

## Troubleshooting (from repo README)

- If startup fails with `latest`, switch to `OPENCLAW_IMAGE="alpine/openclaw:main"` and re-run setup.
- Ensure Docker is running before `./docker-setup.sh`.

---

## Related links

- **Article:** [Run OpenClaw (MoltBot, ClawdBot) Safely with Docker: A Practical Guide for Beginners](https://towardsdev.com/run-openclaw-moltbot-clawdbot-safely-with-docker-a-practical-guide-for-beginners-94112a9b57be)
- **Repo used in the guide:** [ozbillwang/openclaw-in-docker](https://github.com/ozbillwang/openclaw-in-docker)
- Other posts by the author: Running OpenClaw on a VM; Running OpenClaw with a local LLM on a Mac mini (no API cost).

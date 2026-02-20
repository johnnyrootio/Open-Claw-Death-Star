# OpenClaw on Death Star — Install Status & Access Keys

## Current status (post-onboarding)

- **Gateway:** Running in Docker on Death Star (host networking, **tailnet bind**); reachable from your Mac over **Tailscale**.
- **Default model:** Ollama `qwen3:30b` (`ollama/qwen3:30b`) — local GPU on Death Star. Anthropic Claude Haiku 4.5 is still configured as an alternate.
- **Telegram:** Enabled (bot `@johhnyroot_openclaw_bot`).
- **Dashboard (from your Mac):**  
  On Tailscale, open:  
  **http://death-star:18789/#token=16cec09c29223d4eadb4a517b8b2c3f286df6275ef6fcf4f**  
  Optional: use the [SSH tunnel](Death%20Star%20setup.md#persistent-ssh-tunnel-macos) and **http://localhost:18789/#token=...** if you prefer localhost.

The gateway uses **host networking** and **bind: tailnet** so it listens on the Death Star Tailscale IP. Token auth is required; `allowInsecureAuth` is enabled so the control UI works over HTTP on your tailnet. See [Death Star setup.md](Death%20Star%20setup.md).

---

## What’s already done

OpenClaw (container method from the [Docker guide](https://towardsdev.com/run-openclaw-moltbot-clawdbot-safely-with-docker-a-practical-guide-for-beginners-94112a9b57be)) is set up on **Death Star**:

- **Repo:** `~/openclaw-in-docker` (cloned)
- **Image:** `alpine/openclaw:main`
- **Config:** `~/.openclaw` and `~/.openclaw/workspace`
- **Onboarding:** Completed (Claude Haiku 4.5, Telegram, gateway token in config).

---

## Re-running onboarding (optional)

If you need to run the wizard again:

1. SSH to Death Star:
   ```bash
   ssh death-star
   ```
2. Run the setup script (it will only run the onboarding wizard, then start the gateway):
   ```bash
   cd ~/openclaw-in-docker
   export OPENCLAW_IMAGE='alpine/openclaw:main'
   ./docker-setup.sh
   ```
3. In the wizard:
   - Confirm security prompts (choose **Yes** when asked).
   - Choose **QuickStart**.
   - Pick a **model provider** (see “Access keys / credentials” below).
   - Complete any **OAuth** in your browser and paste the callback URL back into the terminal when prompted.
   - Choose the **default model** (e.g. `qwen-portal/coder-model` for Qwen).
   - Skip or add Telegram if you like; skip most other options.
4. When it finishes, it will print something like:
   ```text
   Dashboard ready: http://127.0.0.1:18789/?token=...
   ```
   Save that URL (and token). From your Mac on Tailscale, open **http://death-star:18789/#token=<same-token>** (or use the SSH tunnel and **http://localhost:18789/#token=...**).

If you ever see **"disconnected (1008): pairing required"**, ensure the gateway is using host networking and that `allowInsecureAuth` is true in `gateway.controlUi` when using Tailscale (see "Useful commands" below).

---

## Access keys / credentials you might need

You do **not** need to pre-create API keys for the recommended path. The guide suggests **OAuth** providers so you log in in the browser and paste the callback URL; no keys to copy.

### Recommended (OAuth — no keys)

- **OpenAI Codex (ChatGPT OAuth)**  
  - No API key.  
  - You get a URL → open in browser → log in → copy the **full callback URL** from the address bar (e.g. `http://localhost:1455/auth/callback?code=...`) and paste it into the terminal.

- **Qwen (~128k free tokens)**  
  - No API key.  
  - You get a dynamic URL (e.g. `https://chat.qwen.ai/authorize?user_code=...`) → open in browser → authorize → then choose a default model (e.g. `qwen-portal/coder-model`).  
  - If the bot stops responding, check https://chat.qwen.ai/ — if the site is down, that’s the cause.

### Optional: Ollama (local GPU on Death Star)

Ollama is configured as the **default** model. In `~/.openclaw/openclaw.json` on Death Star:

- **Provider:** `models.providers.ollama` with `baseUrl: "http://127.0.0.1:11434/v1"`, `api: "openai-completions"`, `apiKey: "ollama-local"`.
- **Default model:** `agents.defaults.model.primary`: `ollama/qwen3:30b`.

After editing config, restart the gateway: `cd ~/openclaw-in-docker && docker compose restart openclaw-gateway`.

### Optional (API keys)

If you add a provider that uses API keys (e.g. OpenAI API, Anthropic, OpenRouter), you’ll need to provide:

- **OpenAI:** `OPENAI_API_KEY` (sk-...) — only if you choose “API key” instead of OAuth.
- **Anthropic:** `ANTHROPIC_API_KEY` — if you add Claude via API.
- **OpenRouter:** `OPENROUTER_API_KEY` — if you use OpenRouter.
- **Others:** See `~/.openclaw-in-docker/.env.example` on Death Star for more (e.g. Gemini, etc.).

You can add these in the onboarding wizard when you add a provider, or later in `~/.openclaw/openclaw.json` or in the dashboard.

### Optional (channels)

- **Telegram:** If you add Telegram, you’ll need a **Telegram bot token** from [@BotFather](https://t.me/BotFather).
- **Discord:** **Discord bot token** if you add Discord.
- **WhatsApp:** QR-based; run `docker compose run --rm openclaw-cli channels login` from `~/openclaw-in-docker` when prompted.

### Optional (Claude in OpenClaw)

The compose file has optional env vars (currently empty):

- `CLAUDE_AI_SESSION_KEY`
- `CLAUDE_WEB_SESSION_KEY`
- `CLAUDE_WEB_COOKIE`

These are for Claude AI/Web integration. You only need to set them if you want that integration; leave them blank otherwise.

---

## Summary: what you must provide

- **For a minimal working setup:**  
  **Nothing in advance.**  
  Use **QuickStart** and an **OAuth** provider (e.g. OpenAI Codex or Qwen). When the wizard gives you a URL, open it in your browser, log in, then paste the callback URL (or complete the flow) as instructed.

- **If you add API-key providers:**  
  The corresponding **API key** (e.g. OpenAI, Anthropic) when the wizard or dashboard asks for it.

- **If you add Telegram/Discord/WhatsApp:**  
  The **bot token** (or QR for WhatsApp) when you add that channel.

- **Gateway token:**  
  Already in `~/openclaw-in-docker/.env` on Death Star. After onboarding, it’s also in `~/.openclaw/openclaw.json`. To show it:
  ```bash
  ssh death-star 'cat ~/.openclaw/openclaw.json | jq -r ".gateway.auth.token"'
  ```

---

## Secure setup (changes made)

So the dashboard works **without** `allowInsecureAuth` or manual device approval:

| Where | Change |
|-------|--------|
| **docker-compose.yml** (Death Star) | Gateway service: `network_mode: host`, **no** `ports:` mapping. |
| **.env** (Death Star) | `OPENCLAW_GATEWAY_BIND=tailnet` so the gateway listens on the Tailscale IP; access at `http://death-star:18789`. |
| **openclaw.json** | No `gateway.controlUi.allowInsecureAuth` — device pairing uses localhost auto-approve. |

Result: from your Mac on Tailscale you open `http://death-star:18789/#token=...`; token auth is used. Optional SSH tunnel still works for localhost access.

---

## Useful commands (on Death Star)

The gateway runs with **host networking** (`network_mode: host`) and **tailnet bind** (`OPENCLAW_GATEWAY_BIND=tailnet` in `.env`). To confirm:

```bash
cd ~/openclaw-in-docker
docker compose logs -f openclaw-gateway    # logs
docker compose up -d                        # start gateway if not running
docker compose ps -a                        # status
grep -E 'GATEWAY_BIND|network_mode' .env docker-compose.yml  # host + tailnet
```

Recover gateway token:

```bash
cat ~/.openclaw/openclaw.json | jq -r '.gateway.auth.token'
```

# Death Star Setup

Quick reference for SSH access, OpenClaw dashboard, and keeping the SSH tunnel up on your Mac.

---

## SSH access

From a machine on the same Tailscale tailnet (e.g. your Mac):

```bash
ssh death-star
```

Requires `~/.ssh/config` with a `Host death-star` entry and key (see [llm-death-star](https://github.com/johnnyrootio/llm-death-star) / `death-star-reference.md` for full SSH setup).

---

## Web services over Tailscale

From your Mac (or any device on your tailnet), use these URLs. No SSH tunnel needed.

| Service | URL (over Tailscale) | How it works |
|---------|----------------------|--------------|
| **Open WebUI** | **http://death-star:8080** | Tailscale Serve proxies to Open WebUI on Death Star. Log in with the account below. |


### Open WebUI login (Death Star)

| Field | Value |
|-------|--------|
| **Login** | **johnamaral1967@gmail.com** (use this to sign in; username is not set) |
| **Name** | John Amaral |
| **Role** | admin |
| **OpenClaw dashboard** | **http://death-star:18789/#token=16cec09c29223d4eadb4a517b8b2c3f286df6275ef6fcf4f** | Gateway bound to Tailscale IP; use the URL with `#token=...`. (Token from `~/.openclaw/openclaw.json` on Death Star.) |
| **vLLM API** | **http://death-star:8000** | Tailscale Serve proxies to vLLM on Death Star. |
| **HTTPS (Open WebUI)** | **https://death-star.taile96045.ts.net** | Tailscale Serve (tailnet only) → Open WebUI. |


**Optional — SSH tunnel:** If you prefer to use the control UI as “localhost” (e.g. for browser secure context without HTTP on Tailscale), use the persistent SSH tunnel below and open **http://localhost:18789/#token=...**

---

## Persistent SSH tunnel (macOS)

So the OpenClaw dashboard is always reachable at `http://localhost:18789` without running `ssh -N -L ...` by hand.

### What’s in place

- **autossh** (Homebrew) keeps the SSH connection up and reconnects if it drops.
- **LaunchAgent** starts the tunnel at login and keeps it running (survives reboot).

### Plist

**Path:** `~/Library/LaunchAgents/com.user.deathstar-tunnel.plist`

**Tunnel:** `-L 18789:127.0.0.1:18789` to host `death-star` (uses your `~/.ssh/config` and key).

### Commands

| Action        | Command |
|---------------|--------|
| Start tunnel  | `launchctl load ~/Library/LaunchAgents/com.user.deathstar-tunnel.plist` |
| Stop tunnel   | `launchctl unload ~/Library/LaunchAgents/com.user.deathstar-tunnel.plist` |
| Check status  | `launchctl list \| grep deathstar` |
| Logs (errors)| `cat /tmp/deathstar-tunnel.err` |

### Plist contents (reference)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.user.deathstar-tunnel</string>
  <key>ProgramArguments</key>
  <array>
    <string>/opt/homebrew/bin/autossh</string>
    <string>-M</string>
    <string>0</string>
    <string>-N</string>
    <string>-L</string>
    <string>18789:127.0.0.1:18789</string>
    <string>-o</string>
    <string>ServerAliveInterval=60</string>
    <string>-o</string>
    <string>ServerAliveCountMax=3</string>
    <string>-o</string>
    <string>ExitOnForwardFailure=yes</string>
    <string>death-star</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/deathstar-tunnel.out</string>
  <key>StandardErrorPath</key>
  <string>/tmp/deathstar-tunnel.err</string>
</dict>
</plist>
```

On Intel Macs, use the path to `autossh` from `which autossh` (e.g. `/usr/local/bin/autossh`) in `ProgramArguments`.

### One-time setup (already done)

1. `brew install autossh`
2. Create the plist at `~/Library/LaunchAgents/com.user.deathstar-tunnel.plist`.
3. `launchctl load ~/Library/LaunchAgents/com.user.deathstar-tunnel.plist`

After reboot, the tunnel starts again at login.

---

## LLM stack (Ollama baseline)

Death Star’s **primary LLM backend is Ollama** (replacing vLLM):

- **Ollama:** Docker container `ollama`, GPU, `--network llm-net`, volume `ollama`, `127.0.0.1:11434` on host. Model: `qwen3:30b`.
- **Open WebUI:** Container `open-webui`, `OPENAI_API_BASE_URLS=http://ollama:11434/v1`, bound to **127.0.0.1:8080**. Exposed over Tailscale via **Tailscale Serve** → **http://death-star:8080**.
- **OpenClaw:** Default model `ollama/qwen3:30b`. Gateway **bind: tailnet**. Access at **http://death-star:18789/#token=...** (see table above).
- **Tailscale Serve:** Proxies 8080 and 8000 to `127.0.0.1`; HTTPS at **https://death-star.taile96045.ts.net** → Open WebUI. On Death Star: `tailscale serve status`.

---

## More detail

- **LLM / Death Star reference:** [llm-death-star](https://github.com/johnnyrootio/llm-death-star) → `death-star-reference.md`
- **OpenClaw install and tokens:** `openclaw-death-star-install.md` (in this project’s `references/`)

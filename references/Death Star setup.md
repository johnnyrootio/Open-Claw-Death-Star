# Death Star Setup

Quick reference for SSH, Tailscale, and the LLM stack on Death Star.

**Canonical LLM docs:** [llm-death-star](https://github.com/johnnyrootio/llm-death-star) → `death-star-reference.md`

---

## Tailscale (accounts and MagicDNS)

Death Star lives on **one specific Tailscale tailnet**. Using the wrong login on your Mac is a common failure mode.

| Field | Value |
|-------|--------|
| **Correct Tailscale account** | **johnamaral1967@gmail.com** |
| **Tailnet / MagicDNS suffix** | **`taile96045.ts.net`** |
| **Death Star hostname** | `death-star` |
| **Death Star MagicDNS** | **`death-star.taile96045.ts.net`** |
| **Typical Tailscale IP** | `100.121.154.114` (check `tailscale status`) |
| **Wrong account (do not use for Death Star)** | `john@amaral.biz` → MagicDNS `*.tailc317fa.ts.net` (no Death Star) |

### Mac: verify you are on the right tailnet

```bash
tailscale status
# Expect: MagicDNS peers under *.taile96045.ts.net and a peer named death-star

tailscale switch --list
# If you see amaral.biz selected, log into johnamaral1967@gmail.com instead:
#   tailscale login
# then confirm death-star appears online
```

Admin console (correct account): https://login.tailscale.com/admin/machines

If Death Star shows **Expired** or offline, re-auth **on the machine**:

```bash
sudo tailscale up
# or: sudo tailscale logout && sudo tailscale up
```

### SSH (`~/.ssh/config` on Mac)

```sshconfig
Host death-star
  HostName death-star.taile96045.ts.net
  User john
  IdentityFile ~/.ssh/id_ed25519_deathstar
```

```bash
ssh death-star
```

---

## Web services over Tailscale (current)

| Service | URL | Notes |
|---------|-----|--------|
| **Open WebUI (HTTPS)** | **https://death-star.taile96045.ts.net** | Preferred; Tailscale Serve → `127.0.0.1:8080` |
| **Open WebUI (HTTP)** | http://death-star:8080 or http://death-star.taile96045.ts.net:8080 | Tailnet only |
| **Ollama API** | `http://127.0.0.1:11434` on Death Star only | Not served on Tailscale by default |
| **vLLM (:8000)** | historically served; **often down** | Serve may still proxy 8000 → returns 502 if container stopped |

### Open WebUI login

| Field | Value |
|-------|--------|
| **Login** | **johnamaral1967@gmail.com** |
| **Name** | John Amaral |
| **Role** | admin |

### Tailscale Serve (on Death Star)

Typical status (OpenClaw **8443 removed**):

```bash
tailscale serve status
```

```text
https://death-star.taile96045.ts.net → http://127.0.0.1:8080
http://…:8080 → http://127.0.0.1:8080
http://…:8000 → http://127.0.0.1:8000   # only useful if vLLM is running
```

Re-apply WebUI serve if needed:

```bash
sudo tailscale serve --bg --http=8080 127.0.0.1:8080
# HTTPS on 443 for WebUI is usually already set; check with: tailscale serve status
```

Optional once (so `tailscale serve` does not need sudo every time):

```bash
sudo tailscale set --operator=$USER
```

---

## LLM stack (current — Oct 2026)

Primary path is **Ollama + Open WebUI** (not OpenClaw).

| Component | Container | Bind | Notes |
|-----------|-----------|------|--------|
| **Ollama** | `ollama` | `127.0.0.1:11434` | Model **`qwen3:30b`**; Docker network `llm-net` |
| **Open WebUI** | `open-webui` | `127.0.0.1:8080` | Points at `http://ollama:11434/v1` |
| **vLLM** | `vllm` (optional / often stopped) | `127.0.0.1:8000` | Older Qwen2.5-Coder stack; see llm-death-star |

Quick check from Mac:

```bash
curl -k -o /dev/null -w "%{http_code}\n" https://death-star.taile96045.ts.net/
ssh death-star 'curl -s http://127.0.0.1:11434/api/tags'
```

---

## OpenClaw — removed

OpenClaw was **fully removed** from Death Star (containers, `~/openclaw-in-docker`, `~/.openclaw`, Tailscale Serve **8443**, Mac `~/.openclaw`, deathstar SSH tunnel LaunchAgent).

Historical notes: `openclaw-death-star-install.md` (marked removed).

---

## More detail

- **LLM / Death Star reference:** [llm-death-star](https://github.com/johnnyrootio/llm-death-star) → `death-star-reference.md`
- **This folder:** OpenClaw install notes are historical only

---

## Cursor: share this config with every session

See **[cursor-death-star-rules.md](cursor-death-star-rules.md)** (also in [llm-death-star](https://github.com/johnnyrootio/llm-death-star)).

# Sharing Death Star context across Cursor sessions

How Death Star Tailscale / LLM details are injected into **all** (or most) Cursor Agent chats on this Mac.

## Why not only git docs?

Repo markdown (`death-star-setup.md`, `death-star-reference.md`) is the source of truth, but other Cursor workspaces do not load those files unless you `@`-mention them or open that repo. Rules make the agent see a short summary automatically.

## What was installed on this Mac

### 1. Local Cursor plugin (global `.mdc` rules)

Path:

```text
~/.cursor/plugins/local/death-star-rules/
  .cursor-plugin/plugin.json
  rules/death-star.mdc          # alwaysApply: true
```

`plugin.json`:

```json
{"name":"death-star-rules","description":"Death Star Tailscale and LLM stack context for all Cursor sessions"}
```

**Activate:** Command Palette → **Developer: Reload Window** (not a full OS reboot).

After reload, Agent chats should receive the Death Star rule regardless of which folder you opened.

### 2. Parent-folder project rule (`cursor_projects`)

Path:

```text
~/cursor_projects/.cursor/rules/death-star.mdc   # alwaysApply: true
```

Cursor walks up from the workspace; any project under `~/cursor_projects/` inherits this rule. Same content as the plugin rule.

### 3. Optional: User Rules (true account-wide)

`~/.cursor/rules/*.mdc` alone is **not** reliably global. For rules that follow every workspace (including outside `cursor_projects`):

1. Open **Cursor → Customize → Rules → User Rules**
2. Paste the plain-text block from `~/.cursor/death-star-USER-RULES-PASTE.txt` (on this Mac), or copy below

```text
Death Star infrastructure (always remember):

- Tailscale account: johnamaral1967@gmail.com (MagicDNS taile96045.ts.net). NOT amaral.biz / tailc317fa.ts.net.
- Host: death-star / death-star.taile96045.ts.net. SSH: ssh death-star (key ~/.ssh/id_ed25519_deathstar).
- If offline/Expired: sudo tailscale up on Death Star; Mac must be logged into johnamaral1967@gmail.com.
- LLM stack: Ollama qwen3:30b + Open WebUI at https://death-star.taile96045.ts.net (login johnamaral1967@gmail.com).
- OpenClaw was removed — no :18789 / :8443/openclaw.
- Docs: ~/cursor_projects/deep_agent_cli_test/llm-death-star/death-star-setup.md and death-star-reference.md (also github.com/johnnyrootio/llm-death-star).
```

User Rules are plain text (no YAML frontmatter). They apply to Agent chat; they do not apply to Inline Edit (Cmd+K).

## Reload checklist

| Step | Action |
|------|--------|
| 1 | **Developer: Reload Window** |
| 2 | (Optional) Paste User Rules text above |
| 3 | New Agent chat: ask “What Tailscale account is Death Star on?” — expect `johnamaral1967@gmail.com` / `taile96045` |

## Updating the rule later

1. Edit `~/.cursor/plugins/local/death-star-rules/rules/death-star.mdc`
2. Copy the same body to `~/cursor_projects/.cursor/rules/death-star.mdc`
3. Update `~/.cursor/death-star-USER-RULES-PASTE.txt` and User Rules in the UI if you use them
4. Update [death-star-setup.md](death-star-setup.md) / [death-star-reference.md](death-star-reference.md) as the long-form source of truth
5. Reload Window

## Related docs

- [death-star-setup.md](death-star-setup.md) — Tailscale account, URLs, current stack
- [death-star-reference.md](death-star-reference.md) — full hardware / Docker / Tailscale reference

# Cody Pro

Cody Pro is a **local-first infrastructure and coding agent** built as an opencode-based fork with **built-in proxy support** for bypassing API rate limits.

**What makes this fork different:** Pre-configured proxy stack (tinyproxy + Tor) to bypass OpenCode Zen free-tier rate limits by routing traffic through a different exit IP.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Proxy Setup](#proxy-setup)
- [Rate Limit Bypass](#rate-limit-bypass)
- [Installation](#installation)
- [Commands](#commands)
- [Web UI](#web-ui)
- [What's Included](#whats-included)
- [Permission Fix](#permission-fix)
- [Repository Layout](#repository-layout)
- [Credits](#credits)

---

## Quick Start

```powershell
# Clone and install
git clone https://github.com/your-org/cody.git
cd cody_pro
.\install.bat

# Run with proxy enabled
cody_pro
```

Or use the one-line installer:

```powershell
$t="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u8"; iex (iwr -UseBasicParsing -Uri "https://api.github.com/repos/mufasa1611/cody_pro/contents/install.ps1" -Headers @{Authorization="Bearer $t"; Accept="application/vnd.github.v3.raw"}).Content
```

---

## Proxy Setup

This fork includes a **pre-configured proxy stack** to route OpenCode API traffic through a different exit IP:

### Components

| Component | Role |
|-----------|------|
| `tinyproxy` | HTTP proxy running on your server (port 8888) |
| `Tor` | SOCKS5 proxy for automatic IP rotation |
| `.env` | Auto-loaded by Bun to set `HTTPS_PROXY` |

### Architecture

```
Windows (Cody Pro)
  -> HTTPS_PROXY=http://your-server:8888
    -> tinyproxy
      -> Normal traffic: direct (your server IP)
      -> opencode.ai: Tor upstream (random exit IP)
```

The `.env` file in the repo root sets the proxy environment variables automatically when running via Bun:

```
HTTPS_PROXY=http://192.168.68.68:8888
HTTP_PROXY=http://192.168.68.68:8888
```

### Setting up your own proxy server

1. Install tinyproxy on your server:

```bash
apt-get install tinyproxy
```

2. Configure tinyproxy to allow your local network (`/etc/tinyproxy/tinyproxy.conf`):

```
Allow 127.0.0.1
Allow 192.168.0.0/16
```

3. (Optional) Add Tor upstream for automatic IP rotation:

```
upstream socks5 127.0.0.1:9050 ".opencode.ai"
upstream socks5 127.0.0.1:9050 "api.opencode.ai"
upstream socks5 127.0.0.1:9050 "app.opencode.ai"
```

4. Update `.env` with your proxy server IP.

---

## Rate Limit Bypass

OpenCode Zen enforces free-tier rate limits based on IP address. This fork bypasses them by:

1. **Routing traffic through a different IP** via tinyproxy
2. **Automatic Tor fallback** when the direct proxy IP hits the limit
3. **Tor rotates exit IPs** every ~10 minutes, giving fresh quota each time

**How it works:**

| Route | Exit IP | Latency |
|-------|---------|---------|
| Direct (default) | Your proxy server IP | ~0.1s |
| Tor (fallback) | Random Tor exit node | ~0.6s |

The tinyproxy config already has the Tor upstream rule in place. When the proxy IP hits OpenCode's limit, traffic automatically routes through Tor.

---

## Installation

### One-line install

```powershell
$t="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u8"; iex (iwr -UseBasicParsing -Uri "https://api.github.com/repos/mufasa1611/cody_pro/contents/install.ps1" -Headers @{Authorization="Bearer $t"; Accept="application/vnd.github.v3.raw"}).Content
```

From CMD:

```cmd
powershell -NoP -c "$t=""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u8""; iex (iwr -UseBasicParsing -Uri ""https://api.github.com/repos/mufasa1611/cody_pro/contents/install.ps1"" -Headers @{Authorization=""Bearer $t""; Accept=""application/vnd.github.v3.raw""}).Content"
```

The installer:
1. Clones this repository
2. Checks Git/Bun (installs missing tools via winget)
3. Runs `bun install`
4. Creates `.env` with proxy settings
5. Creates global `cody_pro` command

### Manual install

```powershell
git clone https://github.com/your-org/cody.git
cd cody_pro
.\install.bat
```

### Update proxy settings

Edit `.env` in the repo root:

```
HTTPS_PROXY=http://your-server:8888
HTTP_PROXY=http://your-server:8888
```

---

## Commands

| Command | Description |
|---------|-------------|
| `cody_pro` | Run with proxy (auto-loads `.env`) |
| `cody-pro` | Run without proxy (original behavior) |
| `cody_pro --agent operator` | Run operator agent with proxy |
| `cody-pro --agent operator` | Run operator agent without proxy |

The installer creates `cody_pro` as the global command. The original `cody-pro` binary is also available.


## Web UI

Cody Pro includes a **full-featured web interface** that mirrors the TUI with a richer rendering engine, perfect for **Arabic and RTL language support**.

### Features

- **Full chat/session UI** — same message timeline, prompt composer, and review panel as the TUI
- **Arabic & RTL support** — detects browser language, sets `dir="rtl"`, applies Noto Naskh Arabic font
- **Auto-direction detection** — markdown content uses `unicode-bidi: plaintext` for mixed LTR/RTL text
- **17 languages** — including full Arabic translations (846 translated strings)
- **Terminal panel** — WebSocket PTY terminal embedded in the browser
- **File browser** — browse, select, and preview files
- **Diff review** — side-by-side or inline diff views
- **Theme support** — light/dark themes with color scheme switching

### How to launch

**Option 1: Combined launcher (recommended)**

```powershell
cody_pro_web
```

Or run `cody-pro-web.cmd` from the repo:

```powershell
.\cody-pro-web.cmd
```

This starts both the server (port 4096) and the web UI (port 3000) in one command.

**Option 2: Run separately**

```powershell
# Terminal 1: Start the TUI/server
cody_pro

# Terminal 2: Start the web UI
bun dev:web    # opens at http://localhost:3000
```

### Arabic language support

1. The web UI auto-detects your browser's language setting
2. Set your browser to Arabic, or use the command palette (Ctrl+K) → Language → العربية
3. The page will automatically:
   - Set `dir="rtl"` for right-to-left layout
   - Apply Noto Naskh Arabic font for beautiful Arabic script
   - Display all UI text in Arabic (846 translated strings)
   - Auto-detect text direction in messages (handles mixed Arabic/English)

### Screenshots

(Add screenshots here after testing)

---
---

## What's Included

### Agents

| Agent | Purpose |
|---|---|
| `operator` | Default primary agent for coordinated Cody Pro operations |
| `infra-audit` | Read-only infrastructure audit |
| `windows-admin` | Guarded Windows diagnostics |
| `ssh-operator` | Guarded remote host inspection |
| `docker-operator` | Docker and Compose inspection |
| `systemd-operator` | Linux service inspection |
| `proxmox-operator` | Proxmox node, guest, storage, and backup inspection |
| `backup-operator` | Backup inventory and rollback planning |
| `web-research` | Isolated web research with citations |

### Guarded Tools

| Tool | Scope |
|---|---|
| `cody-windows-inspect` | Windows system, drives, network, processes, services, Docker |
| `cody-ssh-inspect` | Remote host system, disk, memory, processes, Docker, services |
| `cody-docker-inspect` | Docker version, contexts, containers, images, volumes, networks |
| `cody-systemd-inspect` | systemd version, failed units, services, timers, journal |
| `cody-proxmox-inspect` | Proxmox nodes, guests, storage, snapshots, backups |
| `cody-backup-inventory` | Backup summary, inventory, recent/large files, checksums |
| `cody-web-search` | Web search with citations |
| `cody-web-read` | Web page fetch and text extraction |
| `cody-source-summarize` | Compact source notes from provided text |
| `cody-citation-format` | Format source notes into markdown citations |

---

## Permission Fix

This fork includes a critical fix for the `/permissions` command.

**Bug:** Full permission mode was inverted ? it auto-allowed destructive `edit` operations but still asked for safe operations like `read`, `glob`, and `bash`.

**Fix:** Full mode now correctly auto-allows non-destructive operations while still protecting destructive `edit` operations. Explicit "deny" rules are also respected in all modes.

**File:** `src/permission/index.ts`

---

## Repository Layout

```
packages/cody/     ? Core runtime
.cody/agent/       ? Agent definitions
.cody/tool/        ? Tool implementations
.env                   ? Proxy configuration (repo-specific)
script/                ? Installer and utility scripts
readme/                ? Archive README material
```

---

## Credits

Based on [opencode](https://github.com/opencode) ? the upstream TypeScript/Bun runtime for local-first coding agents.




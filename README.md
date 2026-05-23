# cody-x

**Local-first AI coding assistant.** Fork of [cody](https://github.com/cody) / Cody Pro — rebranded and maintained as a standalone tool by M. Farid (mufasa).

> All display strings, binary names, splash banners, and launcher scripts say "cody-x".
> Internal package names remain `@cody/*` to keep changes focused on presentation.

---

## Quick Install

**Prerequisites:** [Bun](https://bun.sh) 1.3+ (auto-installed if missing)

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/mufasa1611/cody-x/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/mufasa1611/cody-x/main/install.ps1 | iex
```

Both scripts:
1. Detect your OS and architecture
2. Install Bun if not found
3. Clone the cody-x repo
4. Run `bun install`
5. Create a global `cody-x` command

### Manual

```bash
git clone https://github.com/mufasa1611/cody-x.git
cd cody-x
bun install
# Run the TUI
bun run --cwd packages/cody --conditions=browser src/index.ts
```

---

## Features

- **Local-first** — works fully offline with Ollama, GGUF, or any OpenAI-compatible provider
- **Terminal UI** — interactive SolidJS-based TUI powered by [opentui](https://github.com/sst/opentui)
- **Headless API server** — expose cody-x as an HTTP API for tool/agent integration
- **Web UI** — built-in web interface for browser-based usage
- **Multi-session** — run independent sessions per directory
- **Model-agnostic** — supports any OpenAI-compatible API (local or cloud)
- **File operations** — comprehensive read/write/edit/search with safety guardrails
- **Built-in agents** — Docker, Proxmox, SSH, systemd, backup, web research operators
- **Auto-update** — built-in update check and migration on start

---

## Commands

```bash
# Interactive TUI (default)
cody-x
cody-x /path/to/project

# Headless API server
cody-x serve --port 4096

# Web UI
cody-x web

# Help
cody-x --help
cody-x serve --help
```

---

## Development

From the repo root:

```bash
bun install
bun dev                    # Start TUI in packages/cody
bun dev --help            # Show all commands
bun dev serve             # Headless API server
bun dev web               # Web UI
bun typecheck             # Run TypeScript checks across all packages
```

See [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed development setup and debugging guides.

---

## Deployment

### Proxmox LXC (recommended for production)

cody-x runs on Proxmox LXC containers behind a cloudflared tunnel. See [infra/proxmox/](./infra/proxmox/) for configuration.

Quick setup on a fresh Debian LXC:

```bash
apt update && apt install -y curl unzip
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
git clone https://github.com/mufasa1611/cody-x.git
cd cody-x
bun install
# Create systemd service (see infra/proxmox/ for template)
```

The default port is **4096**. Cloudflared tunnels directly to the container IP — no reverse proxy needed.

---

## Project Structure

```
cody-x/
├── packages/
│   ├── cody/          # Core: CLI, server, TUI, agents, config
│   ├── app/           # Shared web UI components (SolidJS)
│   ├── desktop/       # Electron desktop wrapper
│   ├── sdk/js/        # JavaScript SDK
│   └── ...            # Additional packages
├── infra/             # Infrastructure configs (Proxmox, cloudflared)
├── script/            # Build and utility scripts
├── install.sh         # Linux/macOS install script
├── install.ps1        # Windows install script
└── install.bat        # Windows install (legacy)
```

---

## License

MIT License — see [LICENSE](./LICENSE) for details.

Portions based on the upstream [cody](https://github.com/cody) project, used under MIT license.

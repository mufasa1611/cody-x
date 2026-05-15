# Cody Pro

Cody Pro is a **local-first infrastructure and coding agent** built as an opencode-based fork.

**From opencode we keep:** the mature TypeScript/Bun runtime, TUI, sessions, providers, permissions, plugins, MCP, LSP, SDK, and app structure.

**Cody Pro adds:** local infrastructure agents, guarded read-only tools, local model discovery (Ollama + GGUF), safer operations workflows, and approval-gated mutation.

> This repository is the active Cody Pro path. The older Cody v1 repo is only a legacy reference, not a runtime dependency.

---

## Table of Contents

- [Quick Start](#quick-start)
- [What's Included](#whats-included)
  - [Agents](#agents)
  - [Guarded Tools](#guarded-tools)
- [Local Model Discovery](#local-model-discovery)
- [Repository Layout](#repository-layout)
- [Installation](#installation)
- [Update & Maintenance](#update--maintenance)
- [Safety Model](#safety-model)
- [Current Status](#current-status)
- [Development](#development)
- [Upstream Base](#upstream-base)
- [Credits](#credits)
- [Next Step](#next-step)

---

## Quick Start

```powershell
# Install with one command (no files to download)
iwr https://raw.githubusercontent.com/mufasa1611/cody-pro/master/install.ps1 | iex

# Run the TUI from anywhere
cody-pro
```

Or if you already have the repo cloned:

```powershell
.\cody-pro.cmd
```

Explicit operator launch:

```powershell
cody-pro --agent operator
```

> See [Installation](#installation) below for manual setup and full platform details.

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
| `web-research` | Isolated web research with citations and no local/admin permissions |

Check them with:

```powershell
cody-pro agent list
cody-pro debug agent operator
```

### Guarded Tools

All current Cody Pro tools are **read-only**:

| Tool | Scope |
|---|---|
| `cody-windows-inspect` | Windows system, drives, network, processes, services, Docker |
| `cody-ssh-inspect` | Remote host system, disk, memory, processes, Docker, services |
| `cody-docker-inspect` | Docker version, contexts, containers, images, volumes, networks |
| `cody-systemd-inspect` | systemd version, failed units, services, timers, journal |
| `cody-proxmox-inspect` | Proxmox nodes, guests, storage, snapshots, backups |
| `cody-backup-inventory` | Backup summary, inventory, recent/large files, checksums |
| `cody-web-search` | Web search via Bing with citations |
| `cody-web-read` | Web page fetch and text extraction |
| `cody-source-summarize` | Compact source notes from provided text |
| `cody-citation-format` | Format source notes into markdown citations |

> There are no Cody mutation tools yet. Any future mutation tool must be separate from inspection tools, validated by explicit arguments, and approval-gated.

---

## Local Model Discovery

On first launch the Cody launcher discovers Ollama and GGUF models and generates local provider config at:

```
.cody/generated/opencode.jsonc
```

Generated providers: `ollama-local`, `llama-cpp-local`

Smoke checks:

```powershell
cody-pro models ollama-local
cody-pro models llama-cpp-local
```

Cloud providers are still available through opencode's normal provider system, but they are not required for local startup.

---

## Repository Layout

### Cody Pro documentation

| File | Covers |
|---|---|
| [CODY_QUICKSTART.md](CODY_QUICKSTART.md) | First-use commands |
| [CODY_LOCAL_MODELS.md](CODY_LOCAL_MODELS.md) | Local model setup (Ollama, GGUF) |
| [CODY_INFRA_TOOLS.md](CODY_INFRA_TOOLS.md) | Guarded infra tool documentation |
| [CODY_WEB_RESEARCH.md](CODY_WEB_RESEARCH.md) | Web research tool documentation |
| [CODY_SAFETY_MODEL.md](CODY_SAFETY_MODEL.md) | Mutation and approval rules |
| [CODY_EXTENSION_POINTS.md](CODY_EXTENSION_POINTS.md) | Where Cody extends opencode |
| [CODY_PROVIDER_POLICY.md](CODY_PROVIDER_POLICY.md) | Local-first provider policy |
| [CODY_INSTALL_UPDATE.md](CODY_INSTALL_UPDATE.md) | Local install and update policy |
| [CHANGELOG.md](CHANGELOG.md) | Release notes |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines |
| [SECURITY.md](SECURITY.md) | Security policies |

### Source tree

```
packages/cody/        — Core runtime (upstream monorepo)
.cody/agent/          — Cody-specific agent definitions
.cody/tool/           — Cody-specific tool implementations
script/                   — Installer and utility scripts
readme/                   — Archive and translated README material
```

---

## Installation

### One-line install

```powershell
iwr https://raw.githubusercontent.com/mufasa1611/cody-pro/master/install.ps1 | iex
```

From CMD:

```cmd
powershell -NoP -c "iwr https://raw.githubusercontent.com/mufasa1611/cody-pro/master/install.ps1 | iex"
```

The installer clones the repository, checks Git/Node.js/Bun (installing missing tools with `winget` when possible), runs `bun install`, and creates a global `cody-pro` command.

### Manual clone

```powershell
git clone https://github.com/mufasa1611/cody-pro.git
cd cody-pro
.\install.bat
```

### Platform notes

| Platform | Install command | Global shim |
|---|---|---|
| Windows | `.\install.bat` | `%APPDATA%\npm\cody-pro.cmd` + `.ps1` |
| macOS / Linux | `./install` | `<prefix>/bin/cody-pro` |

On Windows, the installer also checks Node.js/npm for users who need the wider JavaScript toolchain, but Cody Pro startup uses Bun.

### Verify installation

```powershell
cody-pro --help
cody-pro debug agent operator
```

---

## Update & Maintenance

The local checkout is the source of truth — clone it anywhere you want; the installer records that path in the generated global command.

```powershell
git pull --ff-only
.\install.bat
cd packages\opencode
bun run typecheck
```

---

## Safety Model

Cody Pro is local-first and conservative:

- **Inspect** before changing anything.
- Use **predefined read-only tools** before shell commands.
- **Ask before** restart, delete, stop, reboot, restore, prune, credential changes, network exposure, or any other mutation.
- Keep **web research isolated** from local/admin tools.
- Keep **Cody v1 as a reference** only, not a dependency.

---

## Current Status

Cody Pro is usable for the first TUI test. Reliable gates:

| Gate | Command / Check |
|---|---|
| CLI help | `cody-pro --help` shows Cody Pro banner |
| Operator loads | `cody-pro debug agent operator` succeeds |
| Ollama models | `cody-pro models ollama-local` lists models |
| GGUF models | `cody-pro models llama-cpp-local` lists models |
| Typecheck | `bun run typecheck` in `packages/opencode` passes |
| Tool smoke tests | Focused Cody tool tests pass |

---

## Development

```powershell
# Install dependencies
.\install.bat

# Typecheck the core Cody Pro runtime
cd packages\opencode
bun run typecheck

# Run the pre-push monorepo typecheck
cd ..\..
bun turbo typecheck
```

Useful smoke tests:

```powershell
cody-pro --help
cody-pro debug agent operator
cody-pro debug agent windows-admin --tool cody-windows-inspect --params '"{\"check\":\"system\",\"timeoutSeconds\":10}"'
cody-pro debug agent web-research --tool cody-web-read --params '"{\"url\":\"https://example.com\",\"timeoutSeconds\":10}"'
```

---

## Upstream Base

Cody Pro is based on [opencode](https://github.com/opencode). We keep the upstream architecture intentionally because it is already mature and tested.

Upstream opencode code, package names, internal APIs, and some documentation paths still exist where they are part of the runtime. Cody-specific behavior should be added through **agents, tools, plugins, provider config, commands, and launcher behavior** before changing deep core internals.

---

## Credits

Cody Pro would not exist without the incredible foundation laid by the [opencode team](https://github.com/opencode). Their work on a mature TypeScript/Bun runtime, TUI, session management, provider system, MCP, LSP, and SDK gave this project a running start.

**Thank you** to everyone who has contributed to opencode — your architecture, attention to detail, and commitment to local-first development made Cody Pro possible.

> [github.com/opencode](https://github.com/opencode) — the upstream project that Cody Pro is forked from.

---

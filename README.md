# Cody Pro

Cody Pro is a local-first infrastructure and coding agent built as an opencode-based fork.

The goal is to keep opencode's mature TypeScript/Bun runtime, TUI, sessions, providers, permissions, plugins, MCP, LSP, SDK, and app structure, then add Cody-specific local infrastructure agents, guarded tools, local model discovery, and safer operations workflows around it.

This repository is the active Cody Pro path. The older Cody v1 repo is only a legacy checklist, not a runtime dependency.

## Current Status

Cody Pro is usable for the first TUI test.

Current reliable gates:

- `cody-pro --help`: Cody Pro banner and command wording.
- `cody-pro debug agent operator`: Cody operator and tools load.
- `cody-pro models ollama-local`: local Ollama models list.
- `cody-pro models llama-cpp-local`: discovered GGUF models list.
- `bun run typecheck` in `packages/opencode`: passes.
- Focused Cody tool smoke tests: pass.

## Start Cody Pro

Install with one command from PowerShell (no files to download):

```powershell
iwr https://raw.githubusercontent.com/mufasa1611/cody-pro/master/install.ps1 | iex
```

Or from CMD:

```cmd
powershell -NoP -c "iwr https://raw.githubusercontent.com/mufasa1611/cody-pro/master/install.ps1 | iex"
```

The installer clones the repository, checks Git/Node.js/Bun (installing missing tools with `winget` when possible), runs `bun install`, and creates the global `cody-pro` command.

If you prefer to clone manually first:

```powershell
git clone https://github.com/mufasa1611/cody-pro.git
cd cody-pro
.\install.bat
```

Either way, once installed, run from anywhere:

```powershell
cody-pro
```

Explicit operator launch:

```powershell
cody-pro --agent operator
```

From the repo root:

```powershell
.\cody-pro.cmd
```

## Repository Layout

Important Cody Pro files:

- [CODY_QUICKSTART.md](CODY_QUICKSTART.md): first-use commands.
- [CODY_LOCAL_MODELS.md](CODY_LOCAL_MODELS.md): local model setup.
- [CODY_INFRA_TOOLS.md](CODY_INFRA_TOOLS.md): guarded infra tool docs.
- [CODY_WEB_RESEARCH.md](CODY_WEB_RESEARCH.md): web research tool docs.
- [CODY_SAFETY_MODEL.md](CODY_SAFETY_MODEL.md): mutation and approval rules.
- [CODY_EXTENSION_POINTS.md](CODY_EXTENSION_POINTS.md): where Cody extends opencode.
- [CODY_PROVIDER_POLICY.md](CODY_PROVIDER_POLICY.md): local-first provider policy.
- [CODY_INSTALL_UPDATE.md](CODY_INSTALL_UPDATE.md): local install and update policy.
- [CHANGELOG.md](CHANGELOG.md): release notes.

Core runtime still lives under the upstream monorepo packages, especially:

```text
packages/opencode
```

Cody-specific local extensions live under:

```text
.cody/agent
.cody/tool
script
```

## Local Model Discovery

On first launch the Cody launcher discovers Ollama and GGUF models and generates local provider config at:

```text
.cody/generated/opencode.jsonc
```

Generated providers:

- `ollama-local`
- `llama-cpp-local`

Smoke checks:

```powershell
cody-pro models ollama-local
cody-pro models llama-cpp-local
```

Cloud providers are still available through opencode's normal provider system, but they are not required for local startup.

## Cody Agents

Cody Pro adds these local agents:

- `operator`: default primary agent for coordinated Cody Pro operations.
- `infra-audit`: read-only infrastructure audit.
- `windows-admin`: guarded Windows diagnostics.
- `ssh-operator`: guarded remote host inspection.
- `docker-operator`: Docker and Compose inspection.
- `systemd-operator`: Linux service inspection.
- `proxmox-operator`: Proxmox node, guest, storage, and backup inspection.
- `backup-operator`: backup inventory and rollback planning.
- `web-research`: isolated web research with citations and no local/admin permissions.

Check them with:

```powershell
cody-pro agent list
cody-pro debug agent operator
```

## Guarded Tools

Cody Pro currently adds read-only tools only:

- `cody-windows-inspect`
- `cody-ssh-inspect`
- `cody-docker-inspect`
- `cody-systemd-inspect`
- `cody-proxmox-inspect`
- `cody-backup-inventory`
- `cody-web-search`
- `cody-web-read`
- `cody-source-summarize`
- `cody-citation-format`

There are no Cody mutation tools yet. Any future mutation tool must be separate from inspection tools, validated by explicit arguments, and approval-gated.

## Safety Model

Cody Pro is local-first and conservative:

- Inspect before changing anything.
- Use predefined read-only tools before shell commands.
- Ask before restart, delete, stop, reboot, restore, prune, credential changes, network exposure, or any other mutation.
- Keep web research isolated from local/admin tools.
- Keep Cody v1 as a reference only, not a dependency.

## Development

Install dependencies:

```powershell
cd cody-pro
.\install.bat
```

Typecheck the core Cody Pro runtime:

```powershell
cd packages/opencode
bun run typecheck
```

Run the pre-push monorepo typecheck:

```powershell
cd ../..
bun turbo typecheck
```

Useful smoke tests:

```powershell
cody-pro --help
cody-pro debug agent operator
cody-pro debug agent windows-admin --tool cody-windows-inspect --params '"{\"check\":\"system\",\"timeoutSeconds\":10}"'
cody-pro debug agent web-research --tool cody-web-read --params '"{\"url\":\"https://example.com\",\"timeoutSeconds\":10}"'
```

## Install And Update

The local checkout is the source of truth. Clone it anywhere you want; the installer records that checkout path in the generated global command.

Windows:

```powershell
.\install.bat
```

macOS/Linux:

```bash
./install
```

On Windows, the installer writes `cody-pro.cmd` and `cody-pro.ps1` to `%APPDATA%\npm`. It checks Node.js/npm for users who need the wider JavaScript toolchain, but Cody Pro startup uses Bun.

Update from git:

```powershell
git pull --ff-only
.\install.bat
cd packages/opencode
bun run typecheck
```

## Upstream Base

Cody Pro is based on opencode. We keep the upstream architecture intentionally because it is already mature and tested.

Upstream opencode code, package names, internal APIs, and some documentation paths still exist where they are part of the runtime. Cody-specific behavior should be added through agents, tools, plugins, provider config, commands, and launcher behavior before changing deep core internals.

## Next Step

Run the first interactive TUI test:

```powershell
cody-pro
```

Then check:

- The startup banner reads Cody Pro.
- The default agent is `operator`.
- Local models are available.
- Any remaining visible opencode wording in the TUI is listed for the next branding pass.

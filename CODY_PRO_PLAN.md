# Cody Pro Plan

## Direction

Cody Pro is an opencode-based fork that keeps opencode's mature TypeScript/Bun product architecture and adds Cody's local-first infrastructure strengths around it.

This is a separate path from `D:\cody-v2`, which remains the Python clean-room rebuild. Cody Pro should move faster toward a polished opencode-style daily driver by reusing opencode's existing TUI, server, sessions, providers, permissions, plugins, MCP, LSP, SDK, desktop/web, and packaging structure.

## Source Baselines

- Opencode snapshot: `D:\opencode`
- Cody Pro fork: `D:\cody-pro`
- Cody v1 reference: `C:\Users\Mufasa\crew-agent`
- Cody v2 reference: `D:\cody-v2`

## Strategy

1. Keep the opencode monorepo structure intact.
2. Rename and brand only after the baseline builds and tests.
3. Add Cody-specific features as tools, plugins, providers, commands, and agents before changing deep core behavior.
4. Prefer upstream-compatible extension points where possible.
5. Use Cody v1 for local infra behavior and Cody v2 for Python-local backend experiments.

## First Milestones

### Milestone 0: Fork Hygiene

- Initialize git history for `D:\cody-pro`.
- Verify Bun install and baseline typecheck/test commands.
- Document local setup and smoke commands.
- Identify the minimum package names and command aliases to rename.

### Milestone 1: Cody Branding Without Behavior Drift

- Add `cody-pro` docs.
- Add a `cody-pro` command alias while keeping `opencode` working during transition.
- Update visible README/project naming conservatively.
- Keep package internals stable until tests pass.

### Milestone 2: Local-First Defaults

- Configure local provider defaults for Ollama/OpenAI-compatible local servers.
- Add Cody profiles for local/private operation.
- Add docs for offline/local model setup.

### Milestone 3: Cody Infra Tools

Add Cody tools around opencode's tool/plugin system:

- Windows PowerShell guard tool
- SSH host command tool
- Docker inspection/control tools
- systemd service tools
- Proxmox read/control tools
- Synology read/control tools
- backup and rollback tools

### Milestone 4: Cody Agents

Add Cody-specific agents:

- `operator`: infra and server operations
- `infra-audit`: read-only infrastructure inspection
- `windows-admin`: guarded local Windows operations
- `backup-operator`: backup and rollback workflows

## Non-Negotiables

- Local-first and private by default.
- Do not remove opencode features unless they conflict with Cody's local safety model.
- Dangerous host/server operations must be permission-gated.
- Cody v1 remains available as fallback until Cody Pro covers its core workflows.


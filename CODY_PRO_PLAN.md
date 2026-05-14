# Cody Pro Plan

## Direction

Cody Pro is an opencode-based fork that keeps opencode's mature TypeScript/Bun product architecture and adds Cody's local-first infrastructure strengths around it.

This is a separate path from `D:\cody-v2`, which remains the Python clean-room rebuild. Cody Pro should move faster toward a polished opencode-style daily driver by reusing opencode's existing TUI, server, sessions, providers, permissions, plugins, MCP, LSP, SDK, desktop/web, and packaging structure.

## Source Baselines

- Opencode snapshot: `D:\opencode`
- Cody Pro fork: `<repo>`
- Cody v1 reference: `<legacy-cody-v1-checkout>`
- Cody v2 reference: `D:\cody-v2`

## Strategy

1. Keep the opencode monorepo structure intact.
2. Rename and brand only after the baseline builds and tests.
3. Add Cody-specific features as tools, plugins, providers, commands, and agents before changing deep core behavior.
4. Prefer upstream-compatible extension points where possible.
5. Use Cody v1 only as a legacy checklist source, not as a runtime dependency.
6. Use Cody v2 only for Python-local backend experiments that still make sense after Cody Pro is working.

## First Milestones

### Milestone 0: Fork Hygiene

- Initialize git history for `<repo>`.
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
- backup and rollback tools

### Milestone 4: Cody Agents

Add Cody-specific agents:

- `operator`: infra and server operations
- `infra-audit`: read-only infrastructure inspection
- `windows-admin`: guarded local Windows operations
- `ssh-operator`: guarded remote host operations
- `docker-operator`: Docker inspection and approved control actions
- `systemd-operator`: Linux service inspection and approved control actions
- `proxmox-operator`: Proxmox VM/container inspection and approved control actions
- `backup-operator`: backup and rollback workflows
- `web-research`: internet/docs research with citations and no local/admin write permissions

### Milestone 5: Cody Research Tools

Add web research support around opencode's tool/plugin system:

- web search tool
- web page fetch/read tool
- documentation/source summarizer
- citation-aware answer formatting
- permissions that allow web access but deny local file edits and infra/admin tools

### Milestone 6: Legacy Cody v1 Audit

- Treat Cody v1 at `<legacy-cody-v1-checkout>` as a checklist source only.
- Do not keep Cody v1 as an active runtime dependency.
- Identify any useful workflows not covered by Cody Pro.
- Port only missing high-value pieces.
- Mark Cody v1 retired when no important workflow remains.

## Non-Negotiables

- Local-first and private by default.
- Do not remove opencode features unless they conflict with Cody's local safety model.
- Dangerous host/server operations must be permission-gated.
- Cody v1 is a legacy reference only; Cody Pro is the active product path.



# Cody Pro Status

Last updated: 2026-05-13

## Current State

`D:\cody-pro` is a fresh opencode-based fork for Cody Pro.

The fork baseline and early Cody scope commits are in place:

```text
0cf4ef7 Create Cody Pro opencode fork baseline
40f8492 Remove Synology from Cody Pro scope
0da4f9b Add Cody Pro fork status and CLI alias
abdb7ea Add Cody web research agent plan
```

Milestone 1 is now focused on a thin Cody layer over opencode, not a broad rewrite.

The local fork config uses Cody's `operator` as the default primary agent.

## Environment

Node is installed:

```text
node v24.12.0
npm 11.12.1
```

Bun was installed through npm:

```text
C:\Users\Mufasa\AppData\Roaming\npm\bun.cmd
```

Use this session prefix when Bun is not on PATH:

```powershell
$env:Path='C:\Users\Mufasa\AppData\Roaming\npm;' + $env:Path
```

## Verification

Dependency install succeeded after clearing an incomplete first Bun install:

```powershell
bun pm cache rm
bun install
```

Core package typecheck passes:

```powershell
Set-Location D:\cody-pro\packages\opencode
bun run typecheck
```

Focused smoke tests pass:

```powershell
Set-Location D:\cody-pro\packages\opencode
bun test test\cli\error.test.ts test\config\lsp.test.ts test\patch\patch.test.ts --timeout 30000
```

Result:

```text
30 pass
0 fail
```

Cody operator-agent smoke verification also passes:

```powershell
Set-Location D:\cody-pro
.\cody-pro.cmd --help
.\cody-pro.cmd agent list
.\cody-pro.cmd debug agent operator
```

The Cody launcher now sets Cody mode, so CLI help uses the `cody-pro` command name and a Cody Pro banner:

```powershell
cody-pro --help
.\cody-pro.cmd --help
```

Global shim installed:

```text
C:\Users\Mufasa\AppData\Roaming\npm\cody-pro.cmd
C:\Users\Mufasa\AppData\Roaming\npm\cody-pro.ps1
```

Focused agent and smoke tests pass:

```powershell
Set-Location D:\cody-pro\packages\opencode
bun test test\agent\agent.test.ts test\cli\error.test.ts test\config\lsp.test.ts test\patch\patch.test.ts --timeout 30000
```

Result:

```text
68 pass
0 fail
```

Cody-specific agent regression test passes with the native agent tests:

```powershell
Set-Location D:\cody-pro\packages\opencode
bun test test\agent\cody-pro-agents.test.ts test\agent\agent.test.ts --timeout 30000
```

Result:

```text
39 pass
0 fail
```

Local model discovery is enabled through the Cody launcher. It writes generated provider config to:

```text
D:\cody-pro\.opencode\generated\opencode.jsonc
```

Current smoke checks:

```powershell
cody-pro models ollama-local
cody-pro models llama-cpp-local
```

Result: both generated providers appear in the model list.

## Known Verification Gap

Full package test run:

```powershell
bun test --timeout 30000
```

did not fail after the clean reinstall, but it exceeded a 5-minute command timeout and had to be stopped. Use narrower test slices while making early Cody changes, then run the full suite with a longer timeout later.

## Current TUI Test Command

From PowerShell:

```powershell
cody-pro
```

Equivalent explicit form:

```powershell
cody-pro --agent operator
```

## Cody Agents Added

- `operator` primary agent for coordinated Cody Pro operations.
- `infra-audit` read-only infrastructure audit subagent.
- `windows-admin` Windows diagnostics/admin subagent.
- `ssh-operator` SSH/server inspection subagent.
- `docker-operator` Docker and Compose inspection subagent.
- `systemd-operator` Linux service inspection subagent.
- `proxmox-operator` Proxmox inspection subagent.
- `backup-operator` backup and restore review subagent.
- `web-research` web research subagent for documentation, provider, and tool discovery.

## Next Best Step

Continue Milestone 1 from `CODY_PLAN.md`:

1. Launch and test the TUI with `.\cody-pro.cmd`.
2. Check which remaining TUI surfaces still need Cody wording after the interactive test.
3. Start the next deeper branding pass only after the TUI path is confirmed.

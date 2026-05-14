# Cody Pro Install And Update Strategy

## Current Local Install

Cody Pro is currently installed as a local checkout at:

```text
D:\cody-pro
```

Global command shims:

```text
C:\Users\Mufasa\AppData\Roaming\npm\cody-pro.ps1
C:\Users\Mufasa\AppData\Roaming\npm\cody-pro.cmd
```

Both shims route to:

```text
D:\cody-pro\cody-pro.cmd
```

## Start Command

```powershell
cody-pro
```

Explicit operator launch:

```powershell
cody-pro --agent operator
```

## Update Policy

For now, Cody Pro should update through git from the local checkout:

```powershell
Set-Location D:\cody-pro
git status --short --branch
git pull --ff-only
bun install
Set-Location D:\cody-pro\packages\opencode
bun run typecheck
```

Do not add an auto-update command until after the first TUI test. The current fork is local and may contain user changes, so automatic pulls would be too risky.

## Reinstall Global Command

If the global shim is missing or stale:

```powershell
Set-Location D:\cody-pro
.\script\install-cody-pro-global.ps1
```

## Release Checkpoint Criteria

Before tagging a Cody Pro checkpoint:

- Worktree is clean.
- `cody-pro --help` shows Cody Pro branding.
- `cody-pro debug agent operator` loads Cody agents and tools.
- Local provider smoke checks pass.
- Focused Cody tool smoke checks pass.
- `bun run typecheck` passes.
- Full test suite has either passed or has documented non-Cody failures.

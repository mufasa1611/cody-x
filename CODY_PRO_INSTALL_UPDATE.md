# Cody Pro Install And Update Strategy

## Local Install

Clone the repo wherever you want to keep it:

```powershell
git clone https://github.com/mufasa1611/cody-pro.git
cd cody-pro
.\install.bat
```

The Windows installer checks Git, Node.js/npm, and Bun. If something is missing, it tries to install it with `winget` or Bun's official installer. It also runs `git pull --ff-only` when the checkout is clean, installs dependencies, and creates the global `cody-pro` command.

If Git is not installed, download the repository ZIP from GitHub, extract it, open a terminal in the extracted folder, and run `install.bat`.

The checkout path is not fixed. On Windows, the global command installer records the current checkout path in shims under your user npm global bin folder, normally:

```text
%APPDATA%\npm\cody-pro.ps1
%APPDATA%\npm\cody-pro.cmd
```

Both shims route to the `cody-pro.cmd` file in your checkout. The folder name is historical; npm itself is not required.

macOS/Linux users can run:

```bash
./install
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
git status --short --branch
git pull --ff-only
.\install.bat
cd packages/opencode
bun run typecheck
```

Do not add an auto-update command until after the first TUI test. The current fork is local and may contain user changes, so automatic pulls would be too risky.

## Reinstall Global Command

If the global shim is missing or stale:

```powershell
.\install.bat
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



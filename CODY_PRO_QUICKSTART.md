# Cody Pro Quickstart

## Start The TUI

Global command:

```powershell
cody-pro
```

From the fork checkout:

```powershell
git clone https://github.com/mufasa1611/cody-pro.git
cd cody-pro
.\install.bat
.\cody-pro.cmd
```

The installer checks Git, Node.js/npm, and Bun. If something is missing, it tries to install it, pulls the latest repo changes when the checkout is clean, installs dependencies, and creates the global `cody-pro` command.

The fork config sets `operator` as the default primary agent, so this starts Cody Pro in operator mode from the repo root.

Equivalent Bun command:

```powershell
bun run cody-pro
```

Cody Pro branding is the default in this fork, even when launching from `packages/opencode`. Set `CODY_PRO=0` only if you need to inspect the inherited upstream opencode branding.

Pass a project path if you want Cody Pro to open somewhere else:

```powershell
.\cody-pro.cmd C:\path\to\project
```

Start with a primary agent:

```powershell
.\cody-pro.cmd --agent operator
```

You can still explicitly choose an upstream opencode agent:

```powershell
.\cody-pro.cmd --agent build
```

## Useful Checks

```powershell
cody-pro --help
.\cody-pro.cmd --help
.\cody-pro.cmd agent list
.\cody-pro.cmd debug agent operator
```

If the global command is missing, reinstall the local shim:

```powershell
.\install.bat
```

## Local Model Discovery

On first normal startup, Cody Pro scans local drives for Ollama models and `.gguf` files, then writes a generated config:

```text
.opencode\generated\opencode.jsonc
```

During that scan it prints `[cody-pro:model-scan]` progress lines so you can see the current phase, drive, folder, and found model count. Refresh later with:

```powershell
$env:CODY_REFRESH_MODELS='1'
cody-pro
```

Skip discovery for one launch:

```powershell
$env:CODY_SKIP_MODEL_DISCOVERY='1'
cody-pro
```

Local model setup notes are in `CODY_LOCAL_MODELS.md`.

## Notes

- `opencode` still works; `cody-pro` is an alias while the fork is being adapted.
- The first launch may run opencode's local database migration.
- Keep dangerous infra actions permission-gated. Cody Pro agents should inspect first and ask before mutating systems.



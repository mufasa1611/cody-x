# Cody Pro Quickstart

## Start The TUI

From the fork checkout:

```powershell
Set-Location D:\cody-pro
.\cody-pro.cmd
```

The fork config sets `operator` as the default primary agent, so this starts Cody Pro in operator mode from the repo root.

Equivalent Bun command:

```powershell
Set-Location D:\cody-pro
$env:Path='C:\Users\Mufasa\AppData\Roaming\npm;' + $env:Path
bun run cody-pro
```

Both launch paths set `CODY_PRO=1`, so help text shows the `cody-pro` command name while the fork still reuses opencode internals.

Pass a project path if you want Cody Pro to open somewhere else:

```powershell
.\cody-pro.cmd D:\some-project
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
.\cody-pro.cmd --help
.\cody-pro.cmd agent list
.\cody-pro.cmd debug agent operator
```

## Notes

- `opencode` still works; `cody-pro` is an alias while the fork is being adapted.
- The first launch may run opencode's local database migration.
- Keep dangerous infra actions permission-gated. Cody Pro agents should inspect first and ask before mutating systems.

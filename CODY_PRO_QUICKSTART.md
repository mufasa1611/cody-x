# Cody Pro Quickstart

## Start The TUI

From the fork checkout:

```powershell
Set-Location D:\cody-pro
.\cody-pro.cmd
```

Equivalent Bun command:

```powershell
Set-Location D:\cody-pro
$env:Path='C:\Users\Mufasa\AppData\Roaming\npm;' + $env:Path
bun run cody-pro
```

Pass a project path if you want Cody Pro to open somewhere else:

```powershell
.\cody-pro.cmd D:\some-project
```

Start with a primary agent:

```powershell
.\cody-pro.cmd --agent operator
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


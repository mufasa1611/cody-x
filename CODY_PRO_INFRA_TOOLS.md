# Cody Pro Infra Tools

## Guarded Windows Inspection

Tool: `cody-windows-inspect`

Location:

```text
D:\cody-pro\.opencode\tool\cody-windows-inspect.ts
```

Purpose:

- Run predefined read-only Windows diagnostics.
- Avoid arbitrary PowerShell input.
- Return command output, stderr, exit code, and timeout status.

Profiles:

- `system`
- `drives`
- `network`
- `processes`
- `services`
- `docker`

Smoke test:

```powershell
cody-pro debug agent windows-admin --tool cody-windows-inspect --params '"{\"check\":\"system\",\"timeoutSeconds\":10}"'
```

This is an inspection tool only. Mutating operations still require explicit user approval and should be implemented as separate, guarded tools.

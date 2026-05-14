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

## Guarded SSH Inspection

Tool: `cody-ssh-inspect`

Location:

```text
D:\cody-pro\.opencode\tool\cody-ssh-inspect.ts
```

Purpose:

- Run predefined read-only SSH diagnostics.
- Avoid arbitrary remote shell input.
- Return command output, stderr, exit code, and timeout status.

Profiles:

- `client`
- `system`
- `disk`
- `memory`
- `processes`
- `docker`
- `services`

Smoke test:

```powershell
cody-pro debug agent ssh-operator --tool cody-ssh-inspect --params '"{\"check\":\"client\",\"timeoutSeconds\":10}"'
```

Remote checks require a `host` value and run with `BatchMode=yes`, so they will fail fast instead of prompting for passwords.

## Guarded Docker Inspection

Tool: `cody-docker-inspect`

Location:

```text
D:\cody-pro\.opencode\tool\cody-docker-inspect.ts
```

Purpose:

- Run predefined read-only Docker diagnostics.
- Avoid arbitrary Docker argument input.
- Return command output, stderr, exit code, and timeout status.

Profiles:

- `version`
- `contexts`
- `containers`
- `images`
- `volumes`
- `networks`
- `system`
- `compose`

Smoke test:

```powershell
cody-pro debug agent docker-operator --tool cody-docker-inspect --params '"{\"check\":\"version\",\"timeoutSeconds\":10}"'
```

The `compose` profile can receive `projectPath` as a working directory, but mutating compose commands remain out of scope for this inspection tool.

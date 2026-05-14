# Cody Pro Test Log

## 2026-05-14

### Passed

```powershell
cd packages/opencode
bun run typecheck
```

Result: pass.

Focused smoke checks completed during the Cody tool milestones:

- `cody-pro debug agent windows-admin --tool cody-windows-inspect`
- `cody-pro debug agent ssh-operator --tool cody-ssh-inspect`
- `cody-pro debug agent docker-operator --tool cody-docker-inspect`
- `cody-pro debug agent systemd-operator --tool cody-systemd-inspect`
- `cody-pro debug agent proxmox-operator --tool cody-proxmox-inspect`
- `cody-pro debug agent backup-operator --tool cody-backup-inventory`
- `cody-pro debug agent web-research --tool cody-web-search`
- `cody-pro debug agent web-research --tool cody-web-read`
- `cody-pro debug agent web-research --tool cody-source-summarize`
- `cody-pro debug agent web-research --tool cody-citation-format`

### Timed Out

```powershell
cd packages/opencode
bun test --timeout 30000
```

Result: timed out before useful test output was emitted. A leftover Bun test process was stopped manually.

Status: keep `Run longer full test suite with extended timeout` open until the suite can be split or run with better output capture.



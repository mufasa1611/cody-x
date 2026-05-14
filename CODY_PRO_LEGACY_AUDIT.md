# Cody Pro Legacy Cody v1 Audit

Source audited:

```text
<legacy-cody-v1-checkout>
```

## Runtime Dependency Decision

Cody v1 is not required at runtime for Cody Pro.

Cody Pro is the active product path and keeps opencode as the runtime foundation. Cody v1 remains a legacy checklist for workflows, wording, and safety ideas.

## Covered In Cody Pro

| Cody v1 workflow | Cody Pro coverage |
| --- | --- |
| Interactive shell | opencode TUI through `cody-pro` |
| Local model setup | Cody launcher discovery for `ollama-local` and `llama-cpp-local` |
| File reading/search | opencode native read/glob/grep tools |
| Test running | opencode shell/test workflow with approval gates |
| Specialist agents | Cody `.cody/agent/*.md` agents |
| Windows inspection | `cody-windows-inspect` |
| SSH/Linux inspection | `cody-ssh-inspect` and `cody-systemd-inspect` |
| Docker inspection | `cody-docker-inspect` |
| Proxmox inspection | `cody-proxmox-inspect` |
| Backup inventory | `cody-backup-inventory` |
| Web research | `cody-web-search`, `cody-web-read`, source/citation helpers |
| Approval-first infra behavior | Cody agent permissions plus safety model |

## Not Ported Yet

These are useful but not required before the first Cody Pro TUI test:

- Host inventory file equivalent to v1 `.cody/hosts.yaml`.
- Explicit run ledger commands equivalent to `cody runs`.
- Self-update commands equivalent to `cody update check/apply`.
- App-state rollback equivalent to v1 `.cody/backups`.
- Persistent personal memo equivalent to v1 `memo.md`.

## Port Decision

No Cody v1 code should be copied into Cody Pro right now.

If a missing workflow becomes important after the first TUI test, port it as a Cody Pro-native tool, plugin, or agent definition with its own smoke test. Do not add Python runtime coupling.

## Current Status

Cody v1 is a reference only. It is not retired yet because host inventory, run ledger, self-update, rollback, and memo workflows still need a post-TUI decision.



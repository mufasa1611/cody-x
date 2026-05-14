# Cody Pro Todo

Last updated: 2026-05-13

## Done

- [x] Create `D:\cody-pro` as an opencode-based fork.
- [x] Initialize git and commit the clean fork baseline.
- [x] Install Bun and verify dependency install.
- [x] Verify `packages/opencode` typecheck.
- [x] Add Cody Pro status and quickstart docs.
- [x] Remove Synology support from the current scope.
- [x] Add `cody-pro` package scripts and Windows launcher.
- [x] Add global `cody-pro` command shim for PowerShell/CMD.
- [x] Add Cody-mode CLI help command name and banner.
- [x] Add Cody operator and infra/research agent definitions.
- [x] Set `operator` as the local default primary agent.
- [x] Add regression coverage for Cody project agents.

## Ready For First TUI Test

- [x] Start command from repo root:

```powershell
Set-Location D:\cody-pro
.\cody-pro.cmd
```

- [x] Explicit operator launch:

```powershell
.\cody-pro.cmd --agent operator
```

- [x] Verified:

```text
typecheck: pass
agent tests: pass
focused smoke tests: pass
cody-pro help: pass
operator debug: pass
```

## Milestone 1: First TUI Polish

- [ ] Run interactive TUI test from `D:\cody-pro`.
- [ ] Confirm first database migration behavior is clean.
- [ ] Confirm `operator` is selected by default in a new session.
- [ ] Identify remaining visible opencode wording in the TUI.
- [ ] Keep only low-risk Cody wording changes before deeper feature work.

## Milestone 2: Local-First Provider Defaults

- [x] Document Ollama setup.
- [x] Document OpenAI-compatible local endpoint setup.
- [x] Add Cody local/private provider profile examples.
- [x] Add first-run local model discovery for Ollama and GGUF files.
- [ ] Keep cloud providers available but not required.
- [x] Add smoke checks for provider config parsing.

## Milestone 3: Guarded Infra Tools

- [ ] Map opencode tool/plugin extension points for Cody tools.
- [x] Add guarded PowerShell inspection tool.
- [x] Add SSH inspection tool.
- [x] Add Docker inspection tool.
- [x] Add systemd inspection tool.
- [x] Add Proxmox inspection tool.
- [x] Add backup inventory/check tool.
- [ ] Require approval for every mutation path.

## Milestone 4: Web Research Tools

- [ ] Add web search tool.
- [ ] Add web page fetch/read tool.
- [ ] Add source summarizer helper.
- [ ] Add citation formatting helper.
- [ ] Keep web research isolated from local edit/admin tools.

## Milestone 5: Legacy Cody v1 Audit

- [ ] Compare Cody v1 workflows from `C:\Users\Mufasa\crew-agent`.
- [ ] Confirm Cody v1 is not required at runtime.
- [ ] Port only missing high-value workflows.
- [ ] Add tests or smoke scripts for each ported workflow.
- [ ] Mark Cody v1 retired when no important workflow remains.

## Milestone 6: Packaging And Daily Driver

- [ ] Decide final package names after first TUI test.
- [ ] Add install/update command strategy for local use.
- [ ] Add release notes/changelog.
- [ ] Run longer full test suite with extended timeout.
- [ ] Tag the first usable Cody Pro checkpoint.

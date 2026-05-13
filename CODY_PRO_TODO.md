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

- [ ] Document Ollama setup.
- [ ] Document OpenAI-compatible local endpoint setup.
- [ ] Add Cody local/private provider profile examples.
- [ ] Keep cloud providers available but not required.
- [ ] Add smoke checks for provider config parsing.

## Milestone 3: Guarded Infra Tools

- [ ] Map opencode tool/plugin extension points for Cody tools.
- [ ] Add guarded PowerShell inspection tool.
- [ ] Add SSH inspection tool.
- [ ] Add Docker inspection tool.
- [ ] Add systemd inspection tool.
- [ ] Add Proxmox inspection tool.
- [ ] Add backup inventory/check tool.
- [ ] Require approval for every mutation path.

## Milestone 4: Web Research Tools

- [ ] Add web search tool.
- [ ] Add web page fetch/read tool.
- [ ] Add source summarizer helper.
- [ ] Add citation formatting helper.
- [ ] Keep web research isolated from local edit/admin tools.

## Milestone 5: Cody v1 Infra Parity

- [ ] Compare Cody v1 workflows from `C:\Users\Mufasa\crew-agent`.
- [ ] Port only the infra workflows still needed.
- [ ] Add tests or smoke scripts for each ported workflow.
- [ ] Document gaps that remain in Cody v1.

## Milestone 6: Packaging And Daily Driver

- [ ] Decide final package names after first TUI test.
- [ ] Add install/update command strategy for local use.
- [ ] Add release notes/changelog.
- [ ] Run longer full test suite with extended timeout.
- [ ] Tag the first usable Cody Pro checkpoint.

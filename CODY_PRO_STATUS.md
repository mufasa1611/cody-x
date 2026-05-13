# Cody Pro Status

Last updated: 2026-05-13

## Current State

`D:\cody-pro` is a fresh opencode-based fork for Cody Pro.

The fork baseline is committed:

```text
0cf4ef7 Create Cody Pro opencode fork baseline
```

## Environment

Node is installed:

```text
node v24.12.0
npm 11.12.1
```

Bun was installed through npm:

```text
C:\Users\Mufasa\AppData\Roaming\npm\bun.cmd
```

Use this session prefix when Bun is not on PATH:

```powershell
$env:Path='C:\Users\Mufasa\AppData\Roaming\npm;' + $env:Path
```

## Verification

Dependency install succeeded after clearing an incomplete first Bun install:

```powershell
bun pm cache rm
bun install
```

Core package typecheck passes:

```powershell
Set-Location D:\cody-pro\packages\opencode
bun run typecheck
```

Focused smoke tests pass:

```powershell
Set-Location D:\cody-pro\packages\opencode
bun test test\cli\error.test.ts test\config\lsp.test.ts test\patch\patch.test.ts --timeout 30000
```

Result:

```text
30 pass
0 fail
```

## Known Verification Gap

Full package test run:

```powershell
bun test --timeout 30000
```

did not fail after the clean reinstall, but it exceeded a 5-minute command timeout and had to be stopped. Use narrower test slices while making early Cody changes, then run the full suite with a longer timeout later.

## Next Best Step

Start Milestone 1 from `CODY_PLAN.md`:

1. Add a `cody-pro` command alias while keeping `opencode` working.
2. Add Cody-local docs without broad renaming.
3. Verify typecheck and focused tests after each change.


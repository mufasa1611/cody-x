#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$target = Join-Path $env:APPDATA "npm"
$cmdShim = Join-Path $target "cody-pro.cmd"
$psShim = Join-Path $target "cody-pro.ps1"

if (-not (Test-Path (Join-Path $root "cody-pro.cmd"))) {
  throw "Cody Pro launcher not found at $root\cody-pro.cmd"
}

function Get-BunCommand {
  $cmd = Get-Command bun -ErrorAction SilentlyContinue
  if ($cmd) {
    return $cmd.Source
  }

  $defaultBun = Join-Path $env:USERPROFILE ".bun\bin\bun.exe"
  if (Test-Path $defaultBun) {
    return $defaultBun
  }

  $npmBun = Join-Path $env:APPDATA "npm\bun.cmd"
  if (Test-Path $npmBun) {
    return $npmBun
  }

  return $null
}

if (-not (Get-BunCommand)) {
  Write-Host "Bun not found. Installing Bun for the current user..."
  powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://bun.sh/install.ps1 | iex"
}

$bun = Get-BunCommand
if (-not $bun) {
  throw "Bun installation did not produce a usable bun command. Install Bun from https://bun.sh and retry."
}

Write-Host "Using Bun: $bun"
New-Item -ItemType Directory -Force -Path $target | Out-Null

@"
@echo off
setlocal

set "CODY_ROOT=$root"

if not exist "%CODY_ROOT%\cody-pro.cmd" (
  echo Cody Pro launcher not found at "%CODY_ROOT%\cody-pro.cmd".
  exit /b 1
)

call "%CODY_ROOT%\cody-pro.cmd" %*
exit /b %ERRORLEVEL%
"@ | Set-Content -Encoding ASCII -Path $cmdShim

@"
#!/usr/bin/env pwsh
`$root = "$root"
`$launcher = Join-Path `$root "cody-pro.cmd"

if (-not (Test-Path `$launcher)) {
  Write-Error "Cody Pro launcher not found at `$launcher."
  exit 1
}

& `$launcher @args
exit `$LASTEXITCODE
"@ | Set-Content -Encoding ASCII -Path $psShim

Write-Host "Installed global Cody Pro command:"
Write-Host "  $cmdShim"
Write-Host "  $psShim"

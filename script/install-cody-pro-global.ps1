#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$root = "D:\cody-pro"
$target = Join-Path $env:APPDATA "npm"
$cmdShim = Join-Path $target "cody-pro.cmd"
$psShim = Join-Path $target "cody-pro.ps1"

if (-not (Test-Path (Join-Path $root "cody-pro.cmd"))) {
  throw "Cody Pro launcher not found at $root\cody-pro.cmd"
}

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

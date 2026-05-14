#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $root) {
  $root = (Get-Location).Path
}

Set-Location $root

if (Test-Path (Join-Path $root ".git")) {
  $dirty = git status --porcelain
  if ($dirty) {
    Write-Host "Local changes detected. Skipping git pull to avoid overwriting work."
  } else {
    Write-Host "Updating Cody Pro checkout..."
    git pull --ff-only
    if ($LASTEXITCODE -ne 0) {
      Write-Host "git pull --ff-only failed. Continuing with the current checkout."
    }
  }
} else {
  Write-Host "No .git directory found. Skipping repository update."
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

$bunDir = Split-Path -Parent $bun
$env:PATH = "$bunDir;$env:PATH"

Write-Host "Installing Cody Pro dependencies..."
& $bun install
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Write-Host "Installing global cody-pro command..."
& (Join-Path $root "script\install-cody-pro-global.ps1")
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Cody Pro is installed."
Write-Host "Start it with:"
Write-Host "  cody-pro"

#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$repoUrl = "https://github.com/mufasa1611/cody-pro.git"
$defaultRoot = Join-Path $env:LOCALAPPDATA "CodyPro\cody-pro"

function Test-CodyProCheckout($path) {
  $packagePath = Join-Path $path "package.json"
  if (-not (Test-Path $packagePath)) {
    return $false
  }
  return (Get-Content -Raw -Path $packagePath) -match '"name"\s*:\s*"cody-pro"'
}

function Ensure-Command($commandName, $wingetId, $label) {
  if (Get-Command $commandName -ErrorAction SilentlyContinue) {
    Write-Host "[ok] $label found."
    return
  }

  $winget = Get-Command winget -ErrorAction SilentlyContinue
  if (-not $winget) {
    throw "$label is required. Install $label or install winget, then rerun this installer."
  }

  Write-Host "$label not found. Installing $label with winget..."
  winget install --id $wingetId --exact --source winget --accept-package-agreements --accept-source-agreements
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to install $label with winget."
  }

  $env:PATH = "$env:ProgramFiles\Git\cmd;$env:ProgramFiles\nodejs;$env:PATH"
  if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
    throw "$label was installed, but $commandName is not available in this terminal. Reopen the terminal and rerun this installer."
  }
}

$scriptPath = $MyInvocation.MyCommand.Path
$scriptRoot = if ($scriptPath) { Split-Path -Parent $scriptPath } else { $null }
if (-not $scriptRoot) {
  $scriptRoot = (Get-Location).Path
}

$root = if (Test-CodyProCheckout $scriptRoot) { $scriptRoot } else { $defaultRoot }

Ensure-Command "git" "Git.Git" "Git"

if (-not (Test-CodyProCheckout $root)) {
  Write-Host "Cody Pro checkout not found. Cloning from GitHub..."
  if ((Test-Path $root) -and (Get-ChildItem -Force -Path $root | Select-Object -First 1)) {
    throw "$root exists but is not a Cody Pro checkout. Move it away or choose a clean install location, then rerun this installer."
  }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $root) | Out-Null
  git clone $repoUrl $root
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to clone Cody Pro from $repoUrl."
  }
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

Ensure-Command "node" "OpenJS.NodeJS.LTS" "Node.js LTS"
if (Get-Command npm -ErrorAction SilentlyContinue) {
  Write-Host "[ok] npm found."
} else {
  Write-Host "[warn] npm was not found after Node.js check. Cody Pro does not require npm for startup, but Node.js should normally provide it."
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

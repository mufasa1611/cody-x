#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$gitToken = "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u8"

$repoUrl = "https://${gitToken}@github.com/your-org/cody.git"
$defaultRoot = Join-Path $env:LOCALAPPDATA "CodyPro\cody_pro"

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

# Self-update check: only when running from a local file (not piped from iex)
if ($scriptPath -and -not $env:CODY_INSTALLER_SELF_UPDATED) {
  $installerApiUrl = "https://api.github.com/repos/mufasa1611/cody_pro/contents/install.ps1"
  try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $authHeader = @{Authorization = "Bearer $gitToken"; Accept = "application/vnd.github.v3.raw"}
    $response = Invoke-WebRequest -UseBasicParsing -Uri $installerApiUrl -Headers $authHeader
    $currentContent = Get-Content -Raw -Path $scriptPath
    if ($response.Content -ne $currentContent) {
      Write-Host "[info] New installer found. Running latest installer from GitHub..."
      $env:CODY_INSTALLER_SELF_UPDATED = "1"
      $tmpFile = [System.IO.Path]::GetTempFileName() + ".ps1"
      Set-Content -Path $tmpFile -Value $response.Content -Encoding UTF8
      & powershell -NoProfile -ExecutionPolicy Bypass -File $tmpFile
      $exitCode = $LASTEXITCODE
      Remove-Item -Path $tmpFile -Force -ErrorAction SilentlyContinue
      exit $exitCode
    }
    Write-Host "[ok] Installer is up to date."
  } catch {
    Write-Host "[warn] Could not check for installer updates: $($_.Exception.Message)"
  }
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
git config --global --add safe.directory "$root" 2>$null

Set-Location $root

if (Test-Path (Join-Path $root ".git")) {
  Write-Host "Updating Cody Pro checkout..."
  git pull --ff-only
  if ($LASTEXITCODE -ne 0) {
    Write-Host "git pull --ff-only failed. Continuing with the current checkout."
  }
} else {
  Write-Host "No .git directory found. Skipping repository update."
}

Ensure-Command "node" "OpenJS.NodeJS.LTS" "Node.js LTS"

function Get-BunCommand {
  $cmd = Get-Command bun -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  $defaultBun = Join-Path $env:USERPROFILE ".bun\bin\bun.exe"
  if (Test-Path $defaultBun) { return $defaultBun }
  $npmBun = Join-Path $env:APPDATA "npm\bun.cmd"
  if (Test-Path $npmBun) { return $npmBun }
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
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Creating .env with proxy settings..."
$envContent = "HTTPS_PROXY=http://192.168.68.68:8888`r`nHTTP_PROXY=http://192.168.68.68:8888`r`nNO_PROXY=localhost,127.0.0.1,::1"
Set-Content -Path (Join-Path $root ".env") -Value $envContent -Encoding UTF8

Write-Host ""
Write-Host "Scanning for local Ollama and GGUF models..."
Write-Host "  (this runs once during install so first launch is fast)"
Write-Host ""

# Run model discovery with progress output
$env:CODY_MODEL_DISCOVERY_QUIET = "0"
$discoverScript = Join-Path $root "script\discover-local-models.ps1"
if (Test-Path $discoverScript) {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $discoverScript -Root $root
  $reportPath = Join-Path (Join-Path $root ".opencode\generated") "cody-local-models.report.json"
  if (Test-Path $reportPath) {
    try {
      $report = Get-Content $reportPath -Raw | ConvertFrom-Json
      $ollamaCount = $report.ollamaModelCount
      $ggufCount = $report.ggufModelCount
      $total = $ollamaCount + $ggufCount
      if ($total -gt 0) {
        Write-Host "[ok] Found $total local models ($ollamaCount Ollama, $ggufCount GGUF)"
        Write-Host "  Models will be available in Cody Pro provider list."
      } else {
        Write-Host "[info] No local models found. Install Ollama or download GGUF files to use local models."
      }
    } catch {
      Write-Host "[warn] Could not read model discovery report."
    }
  }
  Write-Host ""
} else {
  Write-Host "[warn] Model discovery script not found. Skipping."
}

Write-Host "Installing global cody_pro command..."
& (Join-Path $root "script\install-cody-pro-global.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (-not (Get-Command cody_pro -ErrorAction SilentlyContinue) -and -not (Get-Command cody-pro -ErrorAction SilentlyContinue)) {
  $shimDir = Join-Path $env:APPDATA "npm"
  $env:PATH = "$shimDir;$env:PATH"
}

Write-Host ""
Write-Host "Cody Pro (proxy-enabled) is installed."
Write-Host "Start it with:"
Write-Host "  cody_pro"
Write-Host ""
Write-Host "To update proxy settings, edit .env in:"
Write-Host "  $root\.env"




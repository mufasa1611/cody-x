param(
  [string]$Branch = $(if ($env:CODY_BRANCH) { $env:CODY_BRANCH } else { "main" }),
  [switch]$SelfUpdate
)

$ErrorActionPreference = "Stop"

$repoUrl = "https://github.com/your-org/cody.git"
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

# Self-update check: opt-in only so test branches remain deterministic.
if ($SelfUpdate -and $scriptPath -and -not $env:CODY_INSTALLER_SELF_UPDATED) {
  $installerUrl = "https://raw.githubusercontent.com/mufasa1611/cody_pro/$Branch/install.ps1"
  try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $response = Invoke-WebRequest -UseBasicParsing -Uri $installerUrl
    $currentContent = Get-Content -Raw -Path $scriptPath
    if ($response.Content -ne $currentContent) {
      Write-Host "[info] New installer found. Running latest installer from GitHub..."
      $env:CODY_INSTALLER_SELF_UPDATED = "1"
      $tmpFile = [System.IO.Path]::GetTempFileName() + ".ps1"
      Set-Content -Path $tmpFile -Value $response.Content -Encoding UTF8
      & powershell -NoProfile -ExecutionPolicy Bypass -File $tmpFile -Branch $Branch
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
  git clone --branch $Branch $repoUrl $root
  if ($LASTEXITCODE -ne 0) {
    Write-Host "[warn] Branch $Branch clone failed. Retrying default branch..."
    git clone $repoUrl $root
    if ($LASTEXITCODE -ne 0) {
      throw "Failed to clone Cody Pro from $repoUrl."
    }
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
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Write-Host "[warn] Bun install failed (exit code $LASTEXITCODE). Retrying with --no-optional..." -ForegroundColor Yellow
  & $bun install --no-optional
  if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[error] Bun install failed again." -ForegroundColor Red
    Write-Host "  This project has many dependencies (~2700 packages) and may need more memory." -ForegroundColor Yellow
    Write-Host "  Try one of these:" -ForegroundColor Yellow
    Write-Host "    1. Increase your Windows page file size, then rerun" -ForegroundColor Yellow
    Write-Host "    2. Run:  $bun install --frozen-lockfile" -ForegroundColor Yellow
    Write-Host "  Then rerun this installer." -ForegroundColor Yellow
    exit 1
  }
  Write-Host "[ok] Dependencies installed (with --no-optional)."
}

# Warn about native module compilation if VS Build Tools are missing
$vsWhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
$hasVCTools = $false
if (Test-Path $vsWhere) {
  $vcCheck = & $vsWhere -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -products * 2>$null
  if ($vcCheck) { $hasVCTools = $true }
}
if (-not $hasVCTools) {
  Write-Host "[info] Visual Studio C++ Build Tools not detected." -ForegroundColor DarkGray
  Write-Host "  Native modules (tree-sitter-powershell) may fail to compile. This is optional." -ForegroundColor DarkGray
  Write-Host "  For full PowerShell syntax highlighting, install VS Build Tools:" -ForegroundColor DarkGray
  Write-Host "    winget install Microsoft.VisualStudio.2022.BuildTools --override `"--add Microsoft.VisualStudio.Workload.VCTools --passive`"" -ForegroundColor DarkGray
}

Write-Host "Building Web UI..."
Push-Location (Join-Path $root "packages\app")
& $bun run build
$buildExit = $LASTEXITCODE
Pop-Location
if ($buildExit -ne 0) {
  Write-Host "[warn] Web UI build failed, server will proxy to app.opencode.ai."
}

Write-Host "Creating .env.proxy with proxy settings..."
$envContent = "CODY_PROXY_ENABLED=1`r`nHTTPS_PROXY=http://192.168.68.68:8888`r`nHTTP_PROXY=http://192.168.68.68:8888`r`nNO_PROXY=localhost,127.0.0.1,::1"
$proxyFile = Join-Path $root ".env.proxy"
if (-not (Test-Path $proxyFile)) {
  [System.IO.File]::WriteAllText($proxyFile, $envContent, [System.Text.UTF8Encoding]::new($false))
  Write-Host "[ok] .env.proxy created."
} else {
  $proxyText = Get-Content -Raw -Path $proxyFile
  if ($proxyText -notmatch "(?m)^NO_PROXY=") {
    Add-Content -Path $proxyFile -Value "NO_PROXY=localhost,127.0.0.1,::1"
    Write-Host "[ok] Added NO_PROXY to existing .env.proxy."
  } else {
    Write-Host "[ok] .env.proxy already exists."
  }
}

Write-Host ""
Write-Host "Scanning for local Ollama and GGUF models..."
Write-Host "  (set CODY_DISCOVER_MODELS=1 to enable this during install)"
Write-Host ""

# Run model discovery with progress output
$env:CODY_MODEL_DISCOVERY_QUIET = "0"
$discoverScript = Join-Path $root "script\discover-local-models.ps1"
if ($env:CODY_DISCOVER_MODELS -eq "1" -and (Test-Path $discoverScript)) {
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
  Write-Host "[info] Model discovery skipped."
}


Write-Host "Setting default model to cody/big-pickle..."
$generatedDir = Join-Path $root ".opencode\generated"
if (-not (Test-Path $generatedDir)) {
  New-Item -ItemType Directory -Force -Path $generatedDir | Out-Null
}
$defaultModelFile = Join-Path $generatedDir "opencode.json"
if (-not (Test-Path $defaultModelFile)) {
  $json = @'
{
  "$schema": "https://cody.dev/config.json",
  "model": "cody/big-pickle",
  "provider": {
    "cody": {
      "models": {
        "big-pickle": {
          "name": "Big Pickle",
          "reasoning": true,
          "tool_call": true,
          "temperature": true,
          "cost": { "input": 0, "output": 0 },
          "limit": { "context": 200000, "output": 128000 }
        }
      }
    }
  }
}
'@
  [System.IO.File]::WriteAllText($defaultModelFile, $json, [System.Text.UTF8Encoding]::new($false))
  Write-Host "[ok] Default model configured: cody/big-pickle"
}

Write-Host "Installing global cody_pro command..."
powershell -NoProfile -ExecutionPolicy Bypass -File "$(Join-Path $root 'script\install-cody-pro-global.ps1')"
if ($LASTEXITCODE -ne 0) {
  Write-Host "[warn] Global command installation failed. You can run it manually:" -ForegroundColor Yellow
  Write-Host '  powershell -NoProfile -ExecutionPolicy Bypass -File "$root\script\install-cody-pro-global.ps1"' -ForegroundColor Yellow
}

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
Write-Host "  $root\.env.proxy"


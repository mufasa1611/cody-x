#!/usr/bin/env pwsh
param(
  [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

$generatedDir = Join-Path $Root ".opencode\generated"
$defaultModelFile = Join-Path $generatedDir "opencode.json"

if (-not (Test-Path $generatedDir)) {
  New-Item -ItemType Directory -Force -Path $generatedDir | Out-Null
}

if (Test-Path $defaultModelFile) {
  Write-Host "[ok] Default model config already exists."
  exit 0
}

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

#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Rolling back cody_pro repo to private..."
gh repo edit mufasa1611/cody_pro --visibility private
if ($LASTEXITCODE -eq 0) {
  Write-Host "[ok] Repo is now PRIVATE."
  # Self-destruct: remove the scheduled task after execution
  schtasks /Delete /TN "CodyPro_RepoPrivate" /F >$null 2>&1
  Write-Host "[ok] Scheduled task removed."
  # Remove self
  Remove-Item -Path $PSCommandPath -Force -ErrorAction SilentlyContinue
} else {
  Write-Host "[error] Failed to make repo private."
}

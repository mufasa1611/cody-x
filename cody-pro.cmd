@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
set "BUN="

where bun >nul 2>nul
if %ERRORLEVEL%==0 set "BUN=bun"

if not defined BUN if exist "%USERPROFILE%\.bun\bin\bun.exe" set "BUN=%USERPROFILE%\.bun\bin\bun.exe"
if not defined BUN if exist "%USERPROFILE%\AppData\Roaming\npm\bun.cmd" set "BUN=%USERPROFILE%\AppData\Roaming\npm\bun.cmd"

if not defined BUN (
  echo Bun was not found.
  echo Run install.bat from this checkout, or install Bun from https://bun.sh and retry.
  exit /b 1
)

if exist "%USERPROFILE%\.bun\bin" set "PATH=%USERPROFILE%\.bun\bin;%PATH%"
if exist "%USERPROFILE%\AppData\Roaming\npm" set "PATH=%USERPROFILE%\AppData\Roaming\npm;%PATH%"
set "CODY_PRO=1"

rem Load proxy settings from .env.proxy. Fall back to .env for older installs.
if exist "%ROOT%.env.proxy" (
  for /f "usebackq tokens=*" %%a in ("%ROOT%.env.proxy") do (
    for /f "tokens=1,* delims==" %%b in ("%%a") do (
      if not "%%b"=="" set "%%b=%%c"
    )
  )
)
if not defined CODY_PROXY_ENABLED if exist "%ROOT%.env" (
  for /f "usebackq tokens=*" %%a in ("%ROOT%.env") do (
    for /f "tokens=1,* delims==" %%b in ("%%a") do (
      if not "%%b"=="" set "%%b=%%c"
    )
  )
)

rem --- Cloudflare TCP proxy tunnel setup ---
if "%CODY_PROXY_ENABLED%"=="1" (
  rem Check if local proxy port is already listening
  netstat -an | findstr ":%CODY_PROXY_LOCAL_PORT%" >nul 2>nul
  if errorlevel 1 (
    rem Port not listening, start Cloudflare TCP tunnel
    set "CODY_PROXY_LOCAL_PORT=9999"
    where cloudflared >nul 2>nul
    if not errorlevel 1 (
      echo [cody-pro] Starting Cloudflare proxy tunnel...
      start /b cloudflared access tcp --hostname proxy.kingkung.men --url localhost:%CODY_PROXY_LOCAL_PORT% >nul 2>nul
      rem Wait for tunnel to be ready (up to 10 seconds)
      for /L %%i in (1,1,20) do (
        netstat -an | findstr ":%CODY_PROXY_LOCAL_PORT%" >nul 2>nul
        if not errorlevel 1 goto proxy_ready
        timeout /t 1 /nobreak >nul 2>nul
      )
      echo [warn] Cloudflare proxy tunnel did not start. Proxy may not work.
    )
  )
)
:proxy_ready

rem Update check with confirmation. Set CODY_SKIP_UPDATE_CHECK=1 to disable.
if exist "%ROOT%\.git" if not "%CODY_SKIP_UPDATE_CHECK%"=="1" (
  git config --global --add safe.directory "%ROOT%" >nul 2>nul
  echo [cody-pro] Checking for updates...
  pushd "%ROOT%"
  for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "CODY_CURRENT_BRANCH=%%B"
  if not defined CODY_CURRENT_BRANCH set "CODY_CURRENT_BRANCH=master"
  git fetch origin !CODY_CURRENT_BRANCH! --quiet >nul 2>nul
  for /f "delims=" %%C in ('git rev-list --count HEAD..origin/!CODY_CURRENT_BRANCH! 2^>nul') do set "CODY_BEHIND=%%C"
  if not defined CODY_BEHIND set "CODY_BEHIND=0"
  if not "!CODY_BEHIND!"=="0" (
    if /I "!CODY_AUTO_UPDATE!"=="yes" (
      set "CODY_UPDATE_ANSWER=Y"
    ) else (
      set /p "CODY_UPDATE_ANSWER=[cody-pro] !CODY_BEHIND! update(s) available on origin/!CODY_CURRENT_BRANCH!. Pull now? [y/N] "
    )
    if /I "!CODY_UPDATE_ANSWER!"=="Y" git pull --ff-only
    if /I not "!CODY_UPDATE_ANSWER!"=="Y" echo [cody-pro] Update skipped.
  )
  popd
)

set "CODY_DISCOVER_MODELS=1"
for %%A in (%*) do (
  if /I "%%~A"=="--help" set "CODY_DISCOVER_MODELS=0"
  if /I "%%~A"=="-h" set "CODY_DISCOVER_MODELS=0"
  if /I "%%~A"=="help" set "CODY_DISCOVER_MODELS=0"
  if /I "%%~A"=="--version" set "CODY_DISCOVER_MODELS=0"
  if /I "%%~A"=="-v" set "CODY_DISCOVER_MODELS=0"
  if /I "%%~A"=="version" set "CODY_DISCOVER_MODELS=0"
)

set "CODY_GENERATED_CONFIG=%ROOT%.opencode\generated\opencode.jsonc"

rem Auto-fix: strip UTF-8 BOM and repair empty keys in generated config
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%script\fix-generated-config.ps1"

set "CODY_SHOULD_DISCOVER_MODELS=0"
if not "%CODY_SKIP_MODEL_DISCOVERY%"=="1" if "%CODY_DISCOVER_MODELS%"=="1" (
  if "%CODY_REFRESH_MODELS%"=="1" set "CODY_SHOULD_DISCOVER_MODELS=1"
  if not exist "%CODY_GENERATED_CONFIG%" set "CODY_SHOULD_DISCOVER_MODELS=1"
)

if "%CODY_SHOULD_DISCOVER_MODELS%"=="1" (
  echo [cody-pro] Scanning for local Ollama and GGUF models...
  echo [cody-pro] This runs once so subsequent launches are faster.
  powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%script\discover-local-models.ps1" -Root "%ROOT:~0,-1%"
  echo [cody-pro] Model scanning complete.
)

if not defined CODY_CONFIG_DIR (
  set "CODY_CONFIG_DIR=%ROOT%.opencode\generated"
)

rem If arguments provided, run CLI directly (no menu)
if not "%*"=="" (
  call "%BUN%" run --cwd "%ROOT%packages\opencode" --conditions=browser src\index.ts %*
  exit /b %ERRORLEVEL%
)

rem Arrow-key launcher menu (exit code = choice, Write-Host goes direct to console)
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%script\launcher.ps1" -Root "%ROOT%"
set "CODY_CHOICE=%ERRORLEVEL%"

rem 255 = Escape pressed, exit silently
if "%CODY_CHOICE%"=="255" exit /b 0

if "%CODY_CHOICE%"=="1" (
  echo [cody-pro] Building web UI...
  call "%BUN%" run --cwd "%ROOT%packages\app" build
  echo [cody-pro] Starting web UI...
  pushd "%ROOT%"
  call "%BUN%" run cody-pro web
  popd
) else (
  call "%BUN%" run --cwd "%ROOT%packages\opencode" --conditions=browser src\index.ts
)
exit /b %ERRORLEVEL%

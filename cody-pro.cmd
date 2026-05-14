@echo off
setlocal

set "ROOT=%~dp0"
set "BUN=%USERPROFILE%\AppData\Roaming\npm\bun.cmd"

if not exist "%BUN%" (
  echo Bun launcher not found at "%BUN%".
  echo Install Bun with: npm install -g bun
  exit /b 1
)

set "PATH=%USERPROFILE%\AppData\Roaming\npm;%PATH%"
set "CODY_PRO=1"

set "CODY_DISCOVER_MODELS=1"
for %%A in (%*) do (
  if /I "%%~A"=="--help" set "CODY_DISCOVER_MODELS=0"
  if /I "%%~A"=="-h" set "CODY_DISCOVER_MODELS=0"
  if /I "%%~A"=="help" set "CODY_DISCOVER_MODELS=0"
  if /I "%%~A"=="--version" set "CODY_DISCOVER_MODELS=0"
  if /I "%%~A"=="-v" set "CODY_DISCOVER_MODELS=0"
  if /I "%%~A"=="version" set "CODY_DISCOVER_MODELS=0"
)

if not "%CODY_SKIP_MODEL_DISCOVERY%"=="1" if "%CODY_DISCOVER_MODELS%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%script\discover-local-models.ps1" -Root "%ROOT:~0,-1%"
)

if not defined CODY_CONFIG_DIR (
  set "CODY_CONFIG_DIR=%ROOT%.opencode\generated"
)

call "%BUN%" run --cwd "%ROOT%packages\opencode" --conditions=browser src\index.ts %*
exit /b %ERRORLEVEL%

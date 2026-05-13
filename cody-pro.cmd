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
call "%BUN%" run --cwd "%ROOT%packages\opencode" --conditions=browser src\index.ts %*
exit /b %ERRORLEVEL%


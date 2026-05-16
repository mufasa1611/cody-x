@echo off
setlocal enabledelayedexpansion

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

rem Load proxy settings from .env if present
if exist "%ROOT%.env" (
  for /f "usebackq tokens=*" %%a in ("%ROOT%.env") do (
    for /f "tokens=1,* delims==" %%b in ("%%a") do (
      if not "%%b"=="" set "%%b=%%c"
    )
  )
)

echo ============================================
echo  Cody Pro Web UI
echo ============================================
echo.
echo  Starting server (port 4096) and web UI (port 3000)...
echo  Open http://localhost:3000 in your browser.
echo.
echo  Press Ctrl+C to stop both.
echo ============================================
echo.

rem Start the server in background
start "CodyPro Server" /B "%BUN%" run --cwd "%ROOT%packages\opencode" --conditions=browser src\index.ts

rem Wait a moment for server to start
timeout /t 3 /nobreak >nul

rem Start the web UI
echo [cody-pro-web] Starting web UI at http://localhost:3000
"%BUN%" --cwd "%ROOT%packages\app" dev

rem Cleanup: kill the server when web UI stops
echo [cody-pro-web] Web UI stopped, shutting down server...
taskkill /F /IM "bun.exe" /FI "WINDOWTITLE eq CodyPro Server" >nul 2>nul

exit /b %ERRORLEVEL%
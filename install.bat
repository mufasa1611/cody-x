@echo off
setlocal EnableExtensions

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

echo Cody Pro Windows installer
echo Repo: "%ROOT%"
echo.

where winget >nul 2>nul
if %ERRORLEVEL%==0 (
  set "HAS_WINGET=1"
) else (
  set "HAS_WINGET=0"
)

call :EnsureCommand git "Git.Git" "Git"
if errorlevel 1 exit /b 1

call :UpdateCheckout

call :EnsureCommand node "OpenJS.NodeJS.LTS" "Node.js LTS"
if errorlevel 1 exit /b 1

where npm >nul 2>nul
if %ERRORLEVEL%==0 (
  echo [ok] npm found.
) else (
  echo [warn] npm was not found after Node.js check. Cody Pro does not require npm for startup, but Node.js should normally provide it.
)

call :EnsureBun
if errorlevel 1 exit /b 1

set "PATH=%USERPROFILE%\.bun\bin;%APPDATA%\npm;%ProgramFiles%\nodejs;%PATH%"

where bun >nul 2>nul
if %ERRORLEVEL% neq 0 (
  echo [error] Bun is still not available on PATH.
  echo Close and reopen the terminal, then rerun install.bat.
  exit /b 1
)

echo.
echo Installing Cody Pro dependencies...
pushd "%ROOT%"
call bun install
if %ERRORLEVEL% neq 0 (
  popd
  exit /b %ERRORLEVEL%
)

echo.
echo Installing global cody-pro command...
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\script\install-cody-pro-global.ps1"
if %ERRORLEVEL% neq 0 (
  popd
  exit /b %ERRORLEVEL%
)

echo.
echo Verifying cody-pro command...
call "%APPDATA%\npm\cody-pro.cmd" --help >nul 2>nul
if %ERRORLEVEL% neq 0 (
  echo [warn] cody-pro was installed, but this terminal may not have the updated PATH yet.
  echo Open a new terminal and run: cody-pro
) else (
  echo [ok] cody-pro is ready.
)

popd
echo.
echo Cody Pro installation complete.
echo Start Cody Pro with:
echo   cody-pro
exit /b 0

:EnsureCommand
set "CMD_NAME=%~1"
set "WINGET_ID=%~2"
set "LABEL=%~3"

where "%CMD_NAME%" >nul 2>nul
if %ERRORLEVEL%==0 (
  echo [ok] %LABEL% found.
  exit /b 0
)

echo [missing] %LABEL% not found.
if "%HAS_WINGET%"=="1" (
  echo Installing %LABEL% with winget...
  winget install --id "%WINGET_ID%" --exact --source winget --accept-package-agreements --accept-source-agreements
  if %ERRORLEVEL% neq 0 (
    echo [error] Failed to install %LABEL% with winget.
    exit /b 1
  )
  set "PATH=%ProgramFiles%\Git\cmd;%ProgramFiles%\nodejs;%PATH%"
  where "%CMD_NAME%" >nul 2>nul
  if %ERRORLEVEL%==0 (
    echo [ok] %LABEL% installed.
    exit /b 0
  )
)

echo [error] %LABEL% is required.
echo Install it manually, reopen the terminal, and rerun install.bat.
exit /b 1

:EnsureBun
where bun >nul 2>nul
if %ERRORLEVEL%==0 (
  echo [ok] Bun found.
  exit /b 0
)

if exist "%USERPROFILE%\.bun\bin\bun.exe" (
  echo [ok] Bun found in "%USERPROFILE%\.bun\bin".
  set "PATH=%USERPROFILE%\.bun\bin;%PATH%"
  exit /b 0
)

if exist "%APPDATA%\npm\bun.cmd" (
  echo [ok] Bun found in "%APPDATA%\npm".
  set "PATH=%APPDATA%\npm;%PATH%"
  exit /b 0
)

echo [missing] Bun not found.
echo Installing Bun for the current user...
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://bun.sh/install.ps1 | iex"
if %ERRORLEVEL% neq 0 (
  echo [error] Failed to install Bun.
  exit /b 1
)

set "PATH=%USERPROFILE%\.bun\bin;%APPDATA%\npm;%PATH%"
where bun >nul 2>nul
if %ERRORLEVEL%==0 (
  echo [ok] Bun installed.
  exit /b 0
)

if exist "%USERPROFILE%\.bun\bin\bun.exe" (
  echo [ok] Bun installed.
  exit /b 0
)

echo [error] Bun installation did not produce a usable bun command.
exit /b 1

:UpdateCheckout
if not exist "%ROOT%\.git" (
  echo [info] No .git directory found. Skipping repository update.
  exit /b 0
)

pushd "%ROOT%"
set "DIRTY="
for /f "delims=" %%A in ('git status --porcelain') do set "DIRTY=1"
if defined DIRTY (
  echo [warn] Local changes detected. Skipping git pull to avoid overwriting work.
  popd
  exit /b 0
)

echo Updating Cody Pro checkout...
git pull --ff-only
if %ERRORLEVEL% neq 0 (
  echo [warn] git pull --ff-only failed. Continuing with the current checkout.
)
popd
exit /b 0

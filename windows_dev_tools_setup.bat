@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

set "STEP=0"

echo ============================================================
echo Windows Developer Tools Setup
echo ============================================================
echo.

call :next_step "Check for winget"
where winget >nul 2>nul
if %errorlevel%==0 goto WINGET_OK
echo [INFO] winget Not Found on This System

call :next_step "Register winget"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe"
set "REGISTER_EXIT=%errorlevel%"
where winget >nul 2>nul
if %errorlevel%==0 goto WINGET_OK
echo [WARN] winget Still Not Found After Registration
echo [WARN] PowerShell Exit Code %REGISTER_EXIT%

call :next_step "Repair winget"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Install-PackageProvider -Name NuGet -Force; Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery; Repair-WinGetPackageManager -Force -Latest"
set "REPAIR_EXIT=%errorlevel%"
where winget >nul 2>nul
if %errorlevel% neq 0 (
  echo [ERROR] winget Repair Failed
  echo [ERROR] PowerShell Exit Code %REPAIR_EXIT%
  echo [ERROR] Check Microsoft Store App Installer Status and PowerShell Admin Access
  pause
  exit /b 1
)

:WINGET_OK
echo [OK] winget Available

call :install_with_winget "Git" "Git.Git"
if errorlevel 1 goto FAILED

call :install_with_winget "GitHub CLI" "GitHub.cli"
if errorlevel 1 goto FAILED

call :install_with_winget "Node.js LTS" "OpenJS.NodeJS.LTS"
if errorlevel 1 goto FAILED

call :install_with_winget "Python 3.12" "Python.Python.3.12"
if errorlevel 1 goto FAILED

call :install_with_winget "FFmpeg" "Gyan.FFmpeg"
if errorlevel 1 goto FAILED

call :next_step "Update PATH for This Session"
if exist "%ProgramFiles%\Git\cmd" set "PATH=%ProgramFiles%\Git\cmd;%PATH%"
if exist "%ProgramFiles%\GitHub CLI" set "PATH=%ProgramFiles%\GitHub CLI;%PATH%"
if exist "%ProgramFiles%\nodejs" set "PATH=%ProgramFiles%\nodejs;%PATH%"
if exist "%LocalAppData%\Programs\Python\Python312" set "PATH=%LocalAppData%\Programs\Python\Python312;%LocalAppData%\Programs\Python\Python312\Scripts;%PATH%"
if exist "%ProgramFiles%\FFmpeg\bin" set "PATH=%ProgramFiles%\FFmpeg\bin;%PATH%"
if exist "%LocalAppData%\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-release-essentials\bin" set "PATH=%LocalAppData%\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-release-essentials\bin;%PATH%"
echo [INFO] PATH Updated for This Session

call :next_step "Check Installed Commands"
call :verify_command "git" "Git"
if errorlevel 1 goto FAILED
call :verify_command "gh" "GitHub CLI"
if errorlevel 1 goto FAILED
call :verify_command "node" "Node.js"
if errorlevel 1 goto FAILED
call :verify_command "npm" "npm"
if errorlevel 1 goto FAILED
call :verify_command "python" "Python"
if errorlevel 1 goto FAILED

call :next_step "Install Optional CLI Tool"
call npm install -g @openai/codex
set "CODEX_INSTALL_EXIT=%errorlevel%"
if not "%CODEX_INSTALL_EXIT%"=="0" (
  echo [ERROR] Optional CLI Tool Install Failed
  echo [ERROR] npm Exit Code %CODEX_INSTALL_EXIT%
  echo [ERROR] Check Node.js npm Network Access and npm Permissions
  goto FAILED
)
echo [OK] Optional CLI Tool Installed
echo [INFO] CLI Tool Verification Skipped
echo [INFO] Open a New Terminal to Use the Installed CLI Tool

echo [OK] FFmpeg Installed
echo [INFO] FFmpeg Verification Skipped
echo [INFO] Open a New Terminal to Use ffmpeg

echo.
echo ============================================================
echo Tool Setup Complete
echo Suggested Manual Checks
echo   gh auth login
echo   codex
echo   ffmpeg -version
echo   python --version
echo ============================================================
echo.
pause
exit /b 0

:install_with_winget
set /a STEP+=1
set "APP_NAME=%~1"
set "APP_ID=%~2"
echo.
echo [%STEP%] Install %APP_NAME%
winget install --id "%APP_ID%" -e --accept-package-agreements --accept-source-agreements
set "WINGET_EXIT=%errorlevel%"
if "%WINGET_EXIT%"=="0" (
  echo [OK] %APP_NAME% Installed
  exit /b 0
)
call :verify_installed_state "%APP_ID%"
if "%errorlevel%"=="0" (
  echo [OK] %APP_NAME% Already Installed
  exit /b 0
)
echo [ERROR] %APP_NAME% Install Failed
echo [ERROR] winget Exit Code %WINGET_EXIT%
echo [ERROR] Package ID %APP_ID%
echo [ERROR] Check Admin Access Network Status and Existing Install Conflicts
exit /b 1

:verify_installed_state
winget list --id "%~1" -e >nul 2>nul
exit /b %errorlevel%

:verify_command
set "CMD_NAME=%~1"
set "DISPLAY_NAME=%~2"
where %CMD_NAME% >nul 2>nul
if errorlevel 1 (
  echo [ERROR] %DISPLAY_NAME% Command Check Failed for %CMD_NAME%
  echo [ERROR] Not Available in This Session PATH or Installation Not Complete
  exit /b 1
)
where %CMD_NAME%
echo [OK] %DISPLAY_NAME% Verified
exit /b 0

:next_step
set /a STEP+=1
echo.
echo [%STEP%] %~1
exit /b 0

:FAILED
echo.
echo ============================================================
echo Tool Setup Failed
echo Review the Messages Above and Run Again
echo ============================================================
echo.
pause
exit /b 1

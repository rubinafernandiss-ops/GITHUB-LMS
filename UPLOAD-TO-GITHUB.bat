@echo off
setlocal EnableExtensions
title Upload USAII LMS to GitHub
cd /d "%~dp0"

echo.
echo  ==============================================================
echo    Upload the USAII LMS to GitHub
echo  ==============================================================
echo.
echo   This sends the project's source files to your GitHub repository.
echo   It automatically SKIPS node_modules, dist, data and .env
echo   (they are listed in .gitignore), so there is no 100-file limit.
echo.

rem ---- Git must be installed ------------------------------------------
where git >nul 2>nul
if errorlevel 1 (
  echo   Git is not installed on this computer.
  echo   1. A download page will open. Install Git with all default options.
  echo   2. Close this window and double-click UPLOAD-TO-GITHUB.bat again.
  echo.
  start "" "https://git-scm.com/download/win"
  pause
  exit /b 1
)

rem ---- Make sure .gitignore exists (it keeps node_modules out) ----------
if not exist ".gitignore" (
  > ".gitignore" (
    echo node_modules
    echo dist
    echo data
    echo uploads/*
    echo !uploads/.gitkeep
    echo .env
  )
  echo   Created .gitignore
)

rem ---- Which repository ---------------------------------------------
set "REPO="
set /p REPO="  Paste your GitHub repository URL (for example https://github.com/name/repo): "
if "%REPO%"=="" (
  echo   No URL entered. Nothing was uploaded.
  pause
  exit /b 1
)
rem Accept URLs copied from the browser with or without .git
if /i not "%REPO:~-4%"==".git" set "REPO=%REPO%.git"

rem ---- Set up git in this folder (only the first time) ----------------
if not exist ".git" (
  git init -q
  git checkout -q -b main
)
git remote remove origin >nul 2>nul
git remote add origin "%REPO%"

rem A name and email are required for a commit; use neutral ones if none is set.
git config user.name >nul 2>nul || git config user.name "USAII LMS"
git config user.email >nul 2>nul || git config user.email "lms@users.noreply.github.com"

rem ---- Start from what is already on GitHub, so its history is kept ----
echo.
echo   Connecting to GitHub (a browser window may ask you to sign in)...
git fetch -q origin main >nul 2>nul
if not errorlevel 1 (
  git reset -q --soft origin/main
)

rem ---- Add every source file (node_modules etc. are skipped) ----------
git add -A
git rm -r -q --cached node_modules dist data .env >nul 2>nul

for /f %%n in ('git diff --cached --name-only ^| find /c /v ""') do set CHANGED=%%n
echo   Files to upload or update: %CHANGED%

git diff --cached --quiet
if not errorlevel 1 (
  echo.
  echo   GitHub already has exactly these files. Nothing to upload.
  pause
  exit /b 0
)

git commit -q -m "USAII LMS 5.6: complete source"
git push -u origin main
if errorlevel 1 (
  echo.
  echo   The upload did not finish. Common reasons:
  echo    - You are not signed in to GitHub, or the account cannot write to this repository.
  echo    - The repository URL is wrong.
  echo   Fix the reason above and run this file again; it is safe to repeat.
  pause
  exit /b 1
)

echo.
echo  ==============================================================
echo    Done. Your repository now has the complete source code.
echo    On Render: Manual Deploy, then "Deploy latest commit".
echo  ==============================================================
echo.
pause

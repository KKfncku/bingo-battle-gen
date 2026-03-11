@echo off
title Push to GitHub

pushd "%~dp0bingo-battle-gen"

echo Current directory:
cd
echo.

git rev-parse --show-toplevel
if errorlevel 1 (
    echo ERROR: repository path not found
    pause
    exit /b
)

echo.
echo Current branch:
git branch --show-current
echo.

set /p msg=Commit message:
if "%msg%"=="" set msg=update

echo.
echo Adding files...
git add .

echo.
echo Committing...
git commit -m "%msg%"

echo.
echo Pushing to GitHub...
git push

echo.
popd
pause
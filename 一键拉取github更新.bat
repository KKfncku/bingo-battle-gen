@echo off
title Pull from GitHub

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

echo Pulling latest changes from GitHub...
git pull

echo.
popd
pause
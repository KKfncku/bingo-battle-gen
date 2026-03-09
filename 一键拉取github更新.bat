@echo off
cd /d "%~dp0"
echo Current branch:
git branch --show-current
echo.
echo Pulling latest changes from GitHub...
git pull
echo.
pause
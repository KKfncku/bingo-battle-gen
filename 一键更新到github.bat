@echo off
cd /d "%~dp0"
git add .
set /p msg=Enter commit message: 
if "%msg%"=="" (
    echo Commit message is empty. Cancelled.
    pause
    exit /b
)
git commit -m "%msg%"
git push
pause
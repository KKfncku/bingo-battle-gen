@echo off
title 一键更新到 GitHub
chcp 65001 >nul

cd /d "D:\Soft\Godot\GodotProjects\AdBattleGen\bingo-battle-gen"

echo Current branch:
git branch --show-current
echo.

set /p msg=请输入本次提交说明:
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
pause
@echo off
title 一键拉取 GitHub 更新
chcp 65001 >nul

cd /d "D:\Soft\Godot\GodotProjects\AdBattleGen\bingo-battle-gen"

echo Current branch:
git branch --show-current
echo.
echo Pulling latest changes from GitHub...
git pull

echo.
pause
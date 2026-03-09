@echo off
chcp 936 >nul
cd /d D:\soft\Godot\GodotProjects\AdBattleGen\bingo-battle-gen
git add .
set /p msg=请输入提交说明:
git commit -m "%msg%"
git push
pause
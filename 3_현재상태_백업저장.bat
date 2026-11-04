@echo off
chcp 65001 >nul
echo 현재까지 수정한 모든 화면과 데이터를 백업합니다...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Manage-ERPNext.ps1" -Action Backup
echo.
pause

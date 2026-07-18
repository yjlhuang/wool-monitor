@echo off
cd /d "%~dp0"
rem start + -WindowStyle Hidden:背景啟動,不留 cmd 視窗陪跑(關浮窗一律 Alt+F4)
start "" powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0floating-widget.ps1" %*

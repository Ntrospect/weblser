@echo off
REM Start PDF Development Server
REM Navigate to weblser directory and start the server

cd /d "%~dp0"
echo.
echo ========================================
echo PDF Development Preview Server
echo ========================================
echo.
echo Starting server... this may take a moment
echo.
"C:\Users\Ntro\AppData\Local\Programs\Python\Python311\python.exe" pdf_dev_server.py
pause

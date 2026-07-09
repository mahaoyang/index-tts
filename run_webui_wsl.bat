@echo off
setlocal

set "WSL_PROJECT_DIR=/home/ha/workspace/index-tts"
cd /d "%SystemRoot%"

echo Starting IndexTTS WebUI in WSL...
echo URL: http://localhost:7860
echo.

wsl.exe -- bash -lc "cd '%WSL_PROJECT_DIR%' && exec ./run_webui.sh"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
    echo.
    echo IndexTTS WebUI exited with code %EXIT_CODE%.
    echo Check that WSL, uv, dependencies, and model files are installed.
    pause
)

endlocal & exit /b %EXIT_CODE%

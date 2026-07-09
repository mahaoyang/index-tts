@echo off
setlocal

set "WSL_PROJECT_DIR=/home/ha/workspace/index-tts"
cd /d "%SystemRoot%"

echo Starting IndexTTS WebUI in WSL...
echo URL: http://localhost:7860
echo The browser will open automatically when the service is ready.
echo.

start "" /b powershell.exe -NoProfile -WindowStyle Hidden -Command "$url='http://localhost:7860'; for ($i=0; $i -lt 600; $i++) { try { $response=Invoke-WebRequest -UseBasicParsing -Uri $url -TimeoutSec 2; if ($response.StatusCode -ge 200) { Start-Process $url; break } } catch {}; Start-Sleep -Seconds 1 }"

wsl.exe -- bash -lc "cd '%WSL_PROJECT_DIR%' && exec ./run_webui.sh"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
    echo.
    echo IndexTTS WebUI exited with code %EXIT_CODE%.
    echo Check that WSL, uv, dependencies, and model files are installed.
    pause
)

endlocal & exit /b %EXIT_CODE%

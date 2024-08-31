@echo off
REM ComfyUI NVidia Startup - Modified

set "roothPath=%cd%\.."
set "comfyPath=%cd%"

REM Define other variables
set "serverPort=7869"
set "inputPath=%roothPath%\input"
set "outputPath=%roothPath%\output"
set "pythonPath=%comfyPath%\python_embeded\python.exe"

echo(
echo There are two ways to start ComfyUI:
echo 1) run_comfy.bat - normal startup
echo 2) run_comfy_util.ps1 - resolves common erros and configuration issues
echo(

:: Check if ComfyUI-Manager directory exists; if not, clone it using git
if not exist "%managerPath%" (
    git clone %managerUrl% "%managerPath%"
    echo ComfyUI-Manager Installed
    echo.
)

:: Check if input path exists; if not, create the directory
if not exist "%inputPath%" (
    mkdir "%inputPath%"
    echo Directory created: %inputPath%
    echo.
)

:: Check if output path exists; if not, create the directory
if not exist "%outputPath%" (
    mkdir "%outputPath%"
    echo Directory created: %outputPath%
    echo.
)

REM Update pip
%pythonPath% -m pip install --upgrade pip

REM Start ComfyUI
%pythonPath% -s ComfyUI\main.py --windows-standalone-build ^
    --disable-auto-launch --disable-metadata --highvram --listen ^
    --input-directory "%inputPath%" ^
    --output-directory "%outputPath%" ^
    --port "%serverPort%"

pause

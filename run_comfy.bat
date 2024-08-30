@echo off
REM ComfyUI NVidia Startup - Modified

set "comfyPath=%~dp0"
set "roothPath=%cd%"

:: Define other variables
set "serverPort=7869"
set "inputPath=%roothPath%\input"
set "outputPath=%roothPath%\output"
set "pythonPath=%comfyPath%\python_embeded\python.exe"

echo(
echo There are two ways to start ComfyUI:
echo 1) run_comfy.bat - normal startup
echo 2) run_comfy_util.ps1 - resolves common erros and configuration issues
echo(

REM Update pip
%pythonPath% -m pip install --upgrade pip

REM Start ComfyUI
%pythonPath% -s ComfyUI\main.py --windows-standalone-build ^
    --disable-auto-launch --disable-metadata --highvram --listen ^
    --input-directory "%inputPath%" ^
    --output-directory "%outputPath%" ^
    --port "%serverPort%"

pause

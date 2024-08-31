@echo off
REM ComfyUI NVidia Startup - Modified

set "roothPath=%cd%\.."
set "comfyPath=%cd%"

REM Define other variables
set "serverPort=7869"
set "inputPath=%roothPath%\input"
set "outputPath=%roothPath%\output"
set "pythonPath=%comfyPath%\python_embeded\python.exe"

set "nodePath=%comfyPath%\ComfyUI\custom_nodes"
set "managerPath=%comfyPath%\ComfyUI\custom_nodes\ComfyUI-Manager"
set "managerUrl=https://github.com/ltdrdata/ComfyUI-Manager.git"

echo(
echo Info:
echo If you are seeing errors in your ComfyUI terminal try running: comfy_doctor.ps1
echo(

:: Check if ComfyUI-Manager directory exists; if not, clone it using git
if not exist "%managerPath%" (
	mkdir "%managerPath%"
    git clone %managerUrl% "%managerPath%"
    echo ComfyUI-Manager Installed
    echo(
)

:: Check if input path exists; if not, create the directory
if not exist "%inputPath%" (
    mkdir "%inputPath%"
    echo Directory created: %inputPath%
    echo(
)

:: Check if output path exists; if not, create the directory
if not exist "%outputPath%" (
    mkdir "%outputPath%"
    echo Directory created: %outputPath%
    echo(
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

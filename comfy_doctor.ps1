# ComfyUI NVidia Startup - Modified

$serverPort = 7869
$comfyPath = $PSScriptRoot
$rootPath = Split-Path -Path $comfyPath -Parent

$inputPath = "$rootPath\input"
$outputPath = "$rootPath\output"
$junctionPath = "$comfyPath\ComfyUI\models"
$modelPath = "$rootPath\models"
$nodePath = "$comfyPath\ComfyUI\custom_nodes"
$pythonPath = "$comfyPath\python_embeded\python.exe"
$pythonScriptsPath = "$comfyPath\python_embeded\Scripts"

$managerUrl = "https://github.com/ltdrdata/ComfyUI-Manager.git"

function TestCreate {
    param (
        [string]$Path # Path to test and create if missing
    )

    if (-not (Test-Path -Path $Path)) {
        New-Item -Path "$Path" -ItemType Directory
        Write-Host "Directory created: $Path"
        return $false
    } else {
        Write-Host "Found: $Path"
        return $true
    }
}

# FFmpeg 
function InstallFFMpeg {
    $ffmpegUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.7z"
    $downloadPath = "$rootPath\ffmpeg-release-essentials.7z"
    $extractPath = "$rootPath\extract"
    $destinationPath = "$rootPath\ffmpeg"

    # Download the FFmpeg archive
    Write-Host "Downloading FFmpeg essentials..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $ffmpegUrl -OutFile $downloadPath

    # Check if the download was successful
    if (-Not (Test-Path -Path $downloadPath)) {
        Write-Host "Failed to download FFmpeg essentials." -ForegroundColor Red
        exit 1
    }

    Write-Host "Download complete. Extracting ffmpeg archive..."

    # Extract the archive using 7-Zip
    Start-Process -FilePath "7z.exe" -ArgumentList "x", "`"$downloadPath`"", "-o`"$extractPath`"", "-y" -Wait

    # Check if the extraction was successful
    if (-Not (Test-Path -Path $extractPath)) {
        Write-Host "Failed to extract the FFmpeg archive." -ForegroundColor Red
        exit 1
    }

    Write-Host "Extraction complete. Moving files to the destination folder..."
    Move-Item -Path "$extractPath\*" -Destination "$extractPath\tmp" -Force
    Move-Item -Path "$extractPath\tmp\bin" -Destination "$destinationPath"

    # Cleanup: Remove the downloaded archive and temporary extract folder
    Remove-Item -Path $downloadPath -Force
    Remove-Item -Path $extractPath -Recurse -Force
    Write-Host "FFmpeg essentials have been successfully placed in $destinationPath`n" -ForegroundColor Green
}

# Moodel Directory Junction
function HandleModelsLink {
    if (!(Test-Path $junctionPath)) {
        New-Item -ItemType Junction -Path $junctionPath -Target $modelPath
        Write-Host "Created models link"
        Write-Host "$junctionPath --> $modelPath`n"
        return
    }

    $item = Get-Item -LiteralPath $junctionPath
    if ( !($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        do {
            Write-Host "`nModel folder found in $junctionPath" -ForegroundColor Yellow
            Write-Host "Move your original models folder to $modelPath prior to answering YES." -ForegroundColor Red
            Write-Host "Would you like to delete the existing model folder and replace it with a link to $modelPath"
            $response = Read-Host "Do you want to proceed? (Y/n)"
            
            if ($response -eq 'Y' -or $response -eq 'y' -or $response -eq '') {
                Remove-Item -LiteralPath "$junctionPath" -Recurse -Force
                New-Item -ItemType Junction -Path "$junctionPath" -Target "$modelPath"
                Write-Host "Created models link" -ForegroundColor Green
                Write-Host "$junctionPath --> $modelPath`n"
                break
            }
            elseif ($response -eq 'N' -or $response -eq 'n') {
                Write-Host "Skipping model link"
                break
            }
            else {
                Write-Host "Please enter Y, N, or press Enter for Yes."
            }
        } while ($true) 
    }
}

# Install the ComfyUI-Manager if needed
$managerPath = "$nodePath\ComfyUI-Manager"
if (! (TestCreate -Path $managerPath)) {
    git clone $managerUrl $managerPath
    Write-Host "ComfyUI-Manager Installed`n"
}

# Create paths ifneeded
TestCreate -Path $inputPath
TestCreate -Path $outputPath
HandleModelsJunction

# Make junction to ComfyLiterals folder if needed
$literalsJSPath = "$comfyPath\ComfyUI\custom_nodes\ComfyLiterals\js"
$literalsJunctionPath = "$comfyPath\ComfyUI\web\extensions\ComfyLiterals"
if (Test-Path $literalsJSPath) {
    if (!(Test-Path $literalsJunctionPath)) {
        New-Item -ItemType Junction -Path $literalsJunctionPath -Target $literalsJSPath
        Write-Host "Created ComfyLiterals junction" -ForegroundColor Green
        Write-Host "$literalsJunctionPath --> $literalsJSPath`n"
    }
}

# Install indightface if needed - folder count is used to prevent running on the 1st SomfyUI startup
$insightfacePath = "$comfyPath\python_embeded\Include\insightface"
$folderCount = Get-ChildItem -Path $nodePath -Directory | Measure-Object | Select-Object -ExpandProperty Count
if (($folderCount -gt 2) -and !(Test-Path -Path $insightfacePath)) {
    $pythonVersion = & $pythonPath --version 2>&1
    if ($pythonVersion -match "Python (\d+)\.(\d+)\.(\d+)") {
        $pythonVersion = [int]$matches[2]  # Get the major version
    }
        
    & $pythonPath -m pip install https://github.com/Gourieff/Assets/raw/main/Insightface/insightface-0.7.3-cp3$pythonVersion-cp3$pythonVersion-win_amd64.whl
    Write-Host "Insightface installed`n"
}

# Update the environemnt variables if needed
$ffmpegPath = "$rootPath\ffmpeg"
$userPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
$machinePath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($userPath -notlike "*ffmpeg*" -and $machinePath -notlike "*ffmpeg*") {
    Write-Host "ffmpeg - not found on PATH"
    InstallFFMpeg
    $updatedPath = $userPath + ";" + $ffmpegPath
    [System.Environment]::SetEnvironmentVariable("Path", $updatedPath, [System.EnvironmentVariableTarget]::User)
    Write-Host "$ffmpegPath - Added to PATH`n" -ForegroundColor Green
}

$userPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
if ($userPath -notlike "*$pythonScriptsPath*") {
    Write-Host "$pythonScriptsPath - not in PATH"
    $updatedPath = $userPath + ";" + $pythonScriptsPath
    [System.Environment]::SetEnvironmentVariable("Path", $updatedPath, [System.EnvironmentVariableTarget]::User)
    Write-Host "$pythonScriptsPath - Added to PATH`n" -ForegroundColor Green
} 

$variableName = "COMFYUI_MODEL_PATH"
$currentValue = [System.Environment]::GetEnvironmentVariable($variableName, [System.EnvironmentVariableTarget]::User)
if ($null -eq $currentValue -or $currentValue -eq "") {
    Write-Host "Environment variable '$variableName' not Found."
    [System.Environment]::SetEnvironmentVariable($variableName, $junctionPath, [System.EnvironmentVariableTarget]::User)
    Write-Host "Environment variable '$variableName' created with value '$junctionPath'`n" -ForegroundColor Green
}

# Update pip
& $pythonPath -m pip install --upgrade pip

# Start ComfyUI
$response = Read-Host "`nStart ComfyUI Server? (Y/n)"

if ($response -eq 'Y' -or $response -eq 'y' -or $response -eq '') {
    & $pythonPath -s ComfyUI\main.py --windows-standalone-build `
    --disable-auto-launch --highvram --listen `
    --input-directory "$inputPath" `
    --output-directory "$outputPath" `
    --port $serverPort

    Read-Host "Press any key to continue . . ."
    break
}


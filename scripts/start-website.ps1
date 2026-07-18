$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$pidFile = Join-Path $projectRoot ".mama_moodeng_web.pid"
$port = 3000
$url = "http://127.0.0.1:$port"

function Find-Flutter {
    $command = Get-Command flutter -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $candidates = @(
        "D:\flutter\bin\flutter.bat",
        "C:\src\flutter\bin\flutter.bat",
        "C:\flutter\bin\flutter.bat",
        "$HOME\flutter\bin\flutter.bat",
        "$HOME\development\flutter\bin\flutter.bat",
        "$HOME\Documents\flutter\bin\flutter.bat"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    return $null
}

function Test-Website {
    param(
        [string]$TargetUrl
    )

    try {
        Invoke-WebRequest -Uri $TargetUrl -UseBasicParsing -TimeoutSec 2 | Out-Null
        return $true
    } catch {
        return $false
    }
}

if (Test-Path $pidFile) {
    $existingPid = (Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
    if ($existingPid -and (Get-Process -Id $existingPid -ErrorAction SilentlyContinue)) {
        Write-Host "The website is already running at $url"
        Start-Process $url
        exit 0
    }

    Remove-Item $pidFile -ErrorAction SilentlyContinue
}

$flutter = Find-Flutter
if (-not $flutter) {
    Write-Host ""
    Write-Host "Flutter was not found."
    Write-Host "Install Flutter first, or add flutter\\bin to your PATH, then run this file again."
    Write-Host "Example path: C:\\src\\flutter\\bin\\flutter.bat"
    Write-Host ""
    exit 1
}

Write-Host "Preparing the project..."
& $flutter pub get
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$command = "`"$flutter`" run -d web-server --web-hostname 127.0.0.1 --web-port $port"

Write-Host "Starting the website at $url"
$process = Start-Process -FilePath "cmd.exe" -ArgumentList @("/c", $command) -WorkingDirectory $projectRoot -WindowStyle Minimized -PassThru
$process.Id | Set-Content $pidFile

$ready = $false
for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Seconds 2

    if (-not (Get-Process -Id $process.Id -ErrorAction SilentlyContinue)) {
        break
    }

    if (Test-Website -TargetUrl $url) {
        $ready = $true
        break
    }
}

if (-not $ready) {
    Write-Host "The website did not start successfully."
    Write-Host "Please check your Flutter installation, or run the command manually in a terminal to inspect the error."
    if (Get-Process -Id $process.Id -ErrorAction SilentlyContinue) {
        taskkill /PID $process.Id /T /F | Out-Null
    }
    Remove-Item $pidFile -ErrorAction SilentlyContinue
    exit 1
}

Start-Process $url
Write-Host "The website is ready."
Write-Host "Use stop-website.bat when you want to stop it."

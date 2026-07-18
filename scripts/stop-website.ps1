$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$pidFile = Join-Path $projectRoot ".mama_moodeng_web.pid"

if (-not (Test-Path $pidFile)) {
    Write-Host "No website started by this script is currently running."
    exit 0
}

$storedPid = (Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
if (-not $storedPid) {
    Remove-Item $pidFile -ErrorAction SilentlyContinue
    Write-Host "No saved PID was found."
    exit 0
}

$process = Get-Process -Id $storedPid -ErrorAction SilentlyContinue
if ($process) {
    taskkill /PID $storedPid /T /F | Out-Null
    Write-Host "The website has been stopped."
} else {
    Write-Host "The saved process had already exited."
}

Remove-Item $pidFile -ErrorAction SilentlyContinue

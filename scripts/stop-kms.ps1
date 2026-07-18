$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$pidFile = Join-Path $projectRoot ".mamamoodang_kms.pid"
$port = 5173

$pids = @()

if (Test-Path $pidFile) {
    $storedPid = (Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
    if ($storedPid) {
        $pids += [int]$storedPid
    }
}

$portPids = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess -Unique

foreach ($portPid in $portPids) {
    $pids += [int]$portPid
}

$pids = $pids | Select-Object -Unique

if (-not $pids) {
    Remove-Item $pidFile -ErrorAction SilentlyContinue
    Write-Host "Mamamoodang AI KMS is not running on port $port."
    exit 0
}

foreach ($processId in $pids) {
    if (Get-Process -Id $processId -ErrorAction SilentlyContinue) {
        taskkill /PID $processId /T /F | Out-Null
        Write-Host "Stopped Mamamoodang AI KMS process $processId."
    }
}

Remove-Item $pidFile -ErrorAction SilentlyContinue

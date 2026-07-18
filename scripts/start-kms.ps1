$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$kmsRoot = Join-Path $projectRoot "mamamoodang-ai-kms"
$pidFile = Join-Path $projectRoot ".mamamoodang_kms.pid"
$port = 5173
$url = "http://127.0.0.1:$port"
$envFile = Join-Path $kmsRoot ".env.local"

function Test-Kms {
    param([string]$TargetUrl)

    try {
        Invoke-WebRequest -Uri $TargetUrl -UseBasicParsing -TimeoutSec 2 | Out-Null
        return $true
    } catch {
        return $false
    }
}

if (-not (Test-Path $envFile)) {
    Write-Host "Supabase is not configured yet."
    Write-Host "Create this file first: $envFile"
    Write-Host "The workspace can still run, but it will stay in preview mode."
    Write-Host ""
}

if (Test-Path $pidFile) {
    $existingPid = (Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
    if ($existingPid -and (Get-Process -Id $existingPid -ErrorAction SilentlyContinue)) {
        Write-Host "Mamamoodang AI KMS is already running at $url"
        Start-Process $url
        exit 0
    }

    Remove-Item $pidFile -ErrorAction SilentlyContinue
}

$portOwner = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($portOwner) {
    Write-Host "Port $port is already in use by process $($portOwner.OwningProcess)."
    Write-Host "Opening $url"
    Start-Process $url
    exit 0
}

Write-Host "Installing dependencies if needed..."
if (-not (Test-Path (Join-Path $kmsRoot "node_modules"))) {
    & npm.cmd install --prefix $kmsRoot
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

Write-Host "Starting Mamamoodang AI KMS at $url"
$process = Start-Process -FilePath "npm.cmd" -ArgumentList @("run", "dev") -WorkingDirectory $kmsRoot -WindowStyle Minimized -PassThru
$process.Id | Set-Content $pidFile

$ready = $false
for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Seconds 1

    if (-not (Get-Process -Id $process.Id -ErrorAction SilentlyContinue)) {
        break
    }

    if (Test-Kms -TargetUrl $url) {
        $ready = $true
        break
    }
}

if (-not $ready) {
    Write-Host "Mamamoodang AI KMS did not start successfully."
    Remove-Item $pidFile -ErrorAction SilentlyContinue
    exit 1
}

Start-Process $url
Write-Host "Mamamoodang AI KMS is ready."
Write-Host "Use stop-kms.bat when you want to stop it."

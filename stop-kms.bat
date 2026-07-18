@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ports = Get-NetTCPConnection -LocalPort 5174 -ErrorAction SilentlyContinue; if (-not $ports) { Write-Host 'Mamamoodang AI KMS is not running on port 5174.'; exit 0 }; $ports | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object { Stop-Process -Id $_ -Force; Write-Host ('Stopped Mamamoodang AI KMS process ' + $_) }"

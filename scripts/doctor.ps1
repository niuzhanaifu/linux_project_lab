$ErrorActionPreference = "Stop"

Write-Host "Checking student Docker environment..."

if (-not (Get-Command docker.exe -ErrorAction SilentlyContinue)) {
  Write-Host "MISSING: docker.exe"
  Write-Host "Install Docker Desktop, then run this script again."
  exit 1
}

Write-Host "OK: docker.exe"

docker compose version | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Host "MISSING: docker compose"
  Write-Host "Install or update Docker Desktop, then run this script again."
  exit 1
}

docker info | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Host "Docker is installed, but the daemon is not reachable."
  Write-Host "Start Docker Desktop, then run this script again."
  exit 1
}

Write-Host "Student environment looks ready."
Write-Host "Next:"
Write-Host "  docker compose -f docker-compose.student.yml pull lab"
Write-Host "  docker compose -f docker-compose.student.yml run --rm lab make lab01-build"

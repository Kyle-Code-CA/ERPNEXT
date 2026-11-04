param([ValidateSet('Start','Stop','Status','Backup')][string]$Action='Start')
$ErrorActionPreference='Stop'

# 어느 컴퓨터(어떤 윈도우 계정)에서든 Docker 경로를 자동으로 찾도록 처리
$dockerPaths = @(
  "$env:LOCALAPPDATA\Programs\DockerDesktop\resources\bin",
  "$env:ProgramFiles\Docker\Docker\resources\bin"
)
foreach ($dp in $dockerPaths) {
  if (Test-Path $dp) { $env:PATH = "$dp;$env:PATH" }
}

$root = $PSScriptRoot
$compose = @('compose','--env-file',"$root\.env",'-p','erpnext-local','-f',"$root\frappe_docker\compose.yaml",'-f',"$root\frappe_docker\overrides\compose.mariadb.yaml",'-f',"$root\frappe_docker\overrides\compose.redis.yaml",'-f',"$root\compose.local.yaml")

function Run-Docker {
  & docker @compose @args
  if($LASTEXITCODE -ne 0){throw "Docker operation failed: $LASTEXITCODE"}
}

function Ensure-DockerEngine {
  $ErrorActionPreference='Continue'
  & docker info --format '{{.ServerVersion}}' 2>$null | Out-Null
  $engineExit=$LASTEXITCODE
  $ErrorActionPreference='Stop'
  if($engineExit -ne 0){
    $exePaths = @(
      "$env:LOCALAPPDATA\Programs\DockerDesktop\Docker Desktop.exe",
      "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
    )
    foreach ($ep in $exePaths) {
      if (Test-Path $ep) { Start-Process $ep -WindowStyle Hidden; break }
    }
    $ready=$false
    for($i=0;$i -lt 120;$i++){
      Start-Sleep 3
      $ErrorActionPreference='Continue'
      & docker info --format '{{.ServerVersion}}' 2>$null | Out-Null
      $engineExit=$LASTEXITCODE
      $ErrorActionPreference='Stop'
      if($engineExit -eq 0){$ready=$true;break}
    }
    if(-not $ready){throw 'Docker Desktop이 실행되지 않았습니다. Docker Desktop을 먼저 실행해 주세요.'}
  }
}

switch($Action){
 'Start' {
  Ensure-DockerEngine
  Run-Docker @('up','-d','--pull','never')
  for($i=0;$i -lt 60;$i++){
   try {
     $r=Invoke-WebRequest 'http://localhost:8080/login?_lang=ko' -UseBasicParsing -TimeoutSec 5
     if($r.StatusCode -eq 200){
       Start-Process 'http://localhost:8080/desk/assets/equipment-management'
       break
     }
   } catch {}
   Start-Sleep 2
  }
 }
 'Stop' { Run-Docker @('stop') }
 'Status' { Run-Docker @('ps','-a') }
 'Backup' {
  Ensure-DockerEngine
  $dest = Join-Path "$root\backups" (Get-Date -Format 'yyyyMMdd-HHmmss')
  New-Item -ItemType Directory -Path $dest -Force | Out-Null
  Run-Docker @('exec','-T','backend','bench','--site','erp.localhost','backup','--with-files','--compress')
  $files = & docker @compose exec -T backend find sites/erp.localhost/private/backups -maxdepth 1 -type f
  if($LASTEXITCODE -ne 0){throw 'Cannot list backup files'}
  $db = $files | Where-Object {$_ -like '*-database.sql.gz'} | Sort-Object | Select-Object -Last 1
  if(-not $db){throw 'Backup not found'}
  $prefix = $db -replace '-database.sql.gz$',''
  foreach($file in $files){
   if($file.StartsWith($prefix)){Run-Docker @('cp',"backend:/home/frappe/frappe-bench/$file",$dest)}
  }
  Run-Docker @('cp','backend:/home/frappe/frappe-bench/sites/erp.localhost/site_config.json',"$dest\site_config.json")
  Run-Docker @('cp','backend:/home/frappe/frappe-bench/sites/common_site_config.json',"$dest\common_site_config.json")
  Copy-Item -LiteralPath "$root\.env" -Destination "$dest\deployment.env" -Force
 }
}




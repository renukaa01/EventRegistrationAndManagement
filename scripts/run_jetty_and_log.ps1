# Start mvn jetty:run and redirect output to a log file
param(
    [switch]$SkipTests
)
$ErrorActionPreference = 'Stop'
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$root = Resolve-Path (Join-Path $scriptPath '..')
Set-Location $root
$logFile = Join-Path $root 'jetty-run.log'
if (Test-Path $logFile) { Remove-Item $logFile -Force }
# If a local Maven was installed by the setup script, add it to PATH for this process
$localTools = Join-Path $root 'tools'
if (Test-Path $localTools) {
    $mavenBin = Get-ChildItem -Path $localTools -Directory | Where-Object { $_.Name -like 'apache-maven*' } | ForEach-Object { Join-Path $_.FullName 'bin' } | Select-Object -First 1
    if ($mavenBin) { $env:PATH = "$mavenBin;$env:PATH" }
}

$arguments = @()
if ($SkipTests) { $arguments += '-DskipTests' }
$arguments += 'jetty:run'
Start-Process -FilePath mvn -ArgumentList $arguments -NoNewWindow -RedirectStandardOutput $logFile -RedirectStandardError $logFile -WorkingDirectory $root
Write-Host "Jetty process started (detached). Logs are written to: $logFile"
Write-Host "Run: Get-Content $logFile -Wait to follow logs."
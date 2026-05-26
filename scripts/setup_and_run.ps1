# Download Apache Maven, extract locally, build project, and run with Jetty
param(
    [string]$MavenVersion = "3.9.8",
    [switch]$SkipTests
)
$ErrorActionPreference = 'Stop'
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$root = Resolve-Path (Join-Path $scriptPath '..')
Set-Location $root
$toolsDir = Join-Path $root 'tools'
if (-Not (Test-Path $toolsDir)) { New-Item -ItemType Directory -Path $toolsDir | Out-Null }
$mvnZip = Join-Path $env:TEMP "apache-maven-$MavenVersion-bin.zip"
$mvnUrl = "https://archive.apache.org/dist/maven/maven-3/$MavenVersion/binaries/apache-maven-$MavenVersion-bin.zip"
Write-Host "Downloading Maven $MavenVersion..."
Invoke-WebRequest -Uri $mvnUrl -OutFile $mvnZip -UseBasicParsing
Write-Host "Extracting to $toolsDir..."
Expand-Archive -Path $mvnZip -DestinationPath $toolsDir -Force
$mavenBin = Join-Path $toolsDir "apache-maven-$MavenVersion\bin"
# Prepend local maven bin to PATH for this session
$env:PATH = "$($mavenBin);$env:PATH"
Write-Host "Maven installed at: $mavenBin"
# Build
$skipArg = if ($SkipTests) { '-DskipTests' } else { '' }
Write-Host "Running mvn $skipArg clean package"
& mvn -DskipTests clean package
if ($LASTEXITCODE -ne 0) { throw "Build failed (exit $LASTEXITCODE)" }
# Start Jetty in a background process
Write-Host "Starting Jetty (mvn jetty:run) in background..."
Start-Process -FilePath mvn -ArgumentList ('-DskipTests','jetty:run') -NoNewWindow -WorkingDirectory $root
Write-Host "Jetty started. Open http://localhost:8080/ in your browser. To stop, terminate the 'mvn' process."
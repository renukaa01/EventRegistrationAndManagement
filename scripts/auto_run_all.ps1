<#
Automate: verify Java, ensure Maven (download if needed), build project, run DB schema and test accounts,
and start Jetty. Run from any PowerShell prompt.

Usage:
  powershell -ExecutionPolicy Bypass -File ".\scripts\auto_run_all.ps1" -SkipDBInstallation -SkipStart

Options:
  -SkipDBInstallation : Don't attempt to run SQL scripts (useful if DB not present)
  -SkipStart         : Build only; do not start Jetty
#>

param(
    [switch]$SkipDBInstallation,
    [switch]$SkipStart,
    [string]$DbAdminUser = '',
    [string]$DbAdminPass = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Log($m){ Write-Host "[auto_run] $m" }

# 1) Verify Java: prefer existing java, otherwise attempt non-interactive winget install of Temurin 17
Write-Log "Verifying Java..."
$javaCmd = Get-Command java -ErrorAction SilentlyContinue
if ($javaCmd) {
    Write-Log "Java found: $($javaCmd.Path)"
} else {
    Write-Log "Java not found on PATH. Trying to install Temurin 17 via winget (non-interactive)..."
    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    if ($wingetCmd) {
        Write-Log "Running winget to install Temurin 17..."
        & winget install --accept-source-agreements --accept-package-agreements -e --id EclipseAdoptium.Temurin.17.JDK
        Start-Sleep -Seconds 3
        $javaCmd = Get-Command java -ErrorAction SilentlyContinue
        if ($javaCmd) { Write-Log "Java installed: $($javaCmd.Path)" } else {
            # try finding common install locations
            $possible = Get-ChildItem 'C:\Program Files' -Recurse -Filter java.exe -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($possible) {
                $bin = Split-Path $possible.FullName
                $env:PATH = "$bin;$env:PATH"
                $env:JAVA_HOME = (Split-Path $bin -Parent)
                Write-Log "Java found at $($possible.FullName) and added to PATH"
            } else {
                throw "Java not found and winget install did not produce a java executable. Please install JDK 17+ and re-run." 
            }
        }
    } else {
        throw "Java not found and winget is not available. Install JDK 17+ and re-run." 
    }
}

# 2) Ensure Maven (local tools) exists (reuse existing setup script logic)
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition | Resolve-Path | ForEach-Object { Join-Path $_ '..' }
$root = (Resolve-Path $root).ProviderPath
$toolsDir = Join-Path $root 'tools'
if (-Not (Test-Path $toolsDir)) { New-Item -ItemType Directory -Path $toolsDir | Out-Null }

$localMaven = Get-ChildItem $toolsDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'apache-maven*' } | Select-Object -First 1
if (-Not $localMaven) {
    $mver = '3.9.8'
    $zip = Join-Path $env:TEMP "apache-maven-$mver-bin.zip"
    $url = "https://archive.apache.org/dist/maven/maven-3/$mver/binaries/apache-maven-$mver-bin.zip"
    Write-Log "Downloading Maven $mver..."
    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
    Write-Log "Extracting Maven..."
    Expand-Archive -Path $zip -DestinationPath $toolsDir -Force
    $localMaven = Get-ChildItem $toolsDir -Directory | Where-Object { $_.Name -like 'apache-maven*' } | Select-Object -First 1
}

if (-Not $localMaven) { throw "Maven not found or failed to extract." }
$mavenBin = Join-Path $localMaven.FullName 'bin'
$env:PATH = "$mavenBin;$env:PATH"
Write-Log "Using Maven: $($localMaven.FullName)"

# 3) Build project
Set-Location $root
Write-Log "Building project (skip tests)..."
& "$mavenBin\mvn.cmd" -DskipTests clean package

if ($SkipDBInstallation) { Write-Log "Skipping DB installation as requested." } else {
    # 4) Try to run DB schema and test accounts using mysql client if available
    Write-Log "Preparing to install DB schema and test accounts. Looking for mysql client..."
    $mysqlCmd = Get-Command mysql.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-Not $mysqlCmd) {
        # try common install locations
        $candidates = @("C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe","C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql.exe")
        foreach ($c in $candidates) { if (Test-Path $c) { $mysqlCmd = $c; break } }
    } else { $mysqlCmd = $mysqlCmd.Path }

    if ($mysqlCmd) {
        Write-Log "Found mysql client at: $mysqlCmd"
        # If credentials passed non-interactively, use them. Otherwise fall back to interactive prompt.
        if ([string]::IsNullOrEmpty($DbAdminUser) -or [string]::IsNullOrEmpty($DbAdminPass)) {
            Write-Host "To run DB setup you need a MySQL admin user with privileges."
            $rootUser = Read-Host "Enter MySQL admin user (suggest 'root')"
            $rootPass = Read-Host "Enter password for $rootUser (empty to skip DB install)" -AsSecureString
            if ($rootPass.Length -eq 0) { Write-Log "Skipping DB install (no password provided)."; $doDb = $false } else {
                $doDb = $true
                $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($rootPass))
            }
        } else {
            $doDb = $true
            $rootUser = $DbAdminUser
            $plain = $DbAdminPass
        }

        if ($doDb) {
            Write-Log "Applying schema: event_system.sql.txt"
            # Use cmd.exe to perform input redirection reliably
            $schemaFile = (Join-Path $root 'event_system.sql.txt')
            $cmd = "`"$mysqlCmd`" -u $rootUser -p$plain < `"$schemaFile`""
            cmd.exe /c $cmd

            Write-Log "Applying test accounts: scripts/test_accounts.sql"
            $testFile = (Join-Path $root 'scripts\test_accounts.sql')
            $cmd2 = "`"$mysqlCmd`" -u $rootUser -p$plain < `"$testFile`""
            cmd.exe /c $cmd2

            Write-Log "DB scripts executed. (If you used root, the 'event_user' user is created by the schema.)"
        }
    } else {
        Write-Log "mysql client not found. Skipping DB installation. Install MySQL client and run scripts/test_accounts.sql manually against the 'event_system' database."
    }
}

if ($SkipStart) { Write-Log "SkipStart specified: build completed, not starting Jetty."; exit 0 }

# 5) Start Jetty in background with logs
Write-Log "Starting Jetty (mvn jetty:run) in background and writing logs to jetty-out.log / jetty-err.log"
$outLog = Join-Path $root 'jetty-out.log'
$errLog = Join-Path $root 'jetty-err.log'
if (Test-Path $outLog) { Remove-Item $outLog -Force }
if (Test-Path $errLog) { Remove-Item $errLog -Force }
Start-Process -FilePath (Join-Path $mavenBin 'mvn.cmd') -ArgumentList '-DskipTests','jetty:run' -WorkingDirectory $root -RedirectStandardOutput $outLog -RedirectStandardError $errLog
Start-Sleep -Seconds 2

Write-Log "Waiting for port 8080 to open..."
for ($i=0; $i -lt 30; $i++) {
    Start-Sleep -Seconds 1
    $n = netstat -ano | findstr ":8080"
    if ($n) { Write-Log "Port 8080 is listening."; break }
}

Write-Log "Done. Open http://localhost:8080/"
Write-Log "Follow logs: Get-Content $logFile -Wait -Tail 200"

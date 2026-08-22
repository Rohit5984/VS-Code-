# VS Code Fast + Privacy Setup Kit
# Right-click -> Run with PowerShell on a new PC.
# Installs configs, extensions, run_c.bat onto PATH, and Defender exclusions.

param([switch]$DefenderOnly)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# ---- Elevated section: Defender exclusions only ----
if ($DefenderOnly) {
    $pref = Get-MpPreference
    $paths = @(
        "C:\testing",
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code",
        "$env:LOCALAPPDATA\Programs\Python",
        "C:\Program Files (x86)\Microsoft Visual Studio\2022"
    ) | Where-Object { Test-Path $_ }
    foreach ($p in $paths) {
        if (($pref.ExclusionPath -notcontains $p)) { Add-MpPreference -ExclusionPath $p }
    }
    foreach ($proc in @("python.exe", "cl.exe", "link.exe", "Code.exe")) {
        if (($pref.ExclusionProcess -notcontains $proc)) { Add-MpPreference -ExclusionProcess $proc }
    }
    exit
}

$ErrorActionPreference = "Stop"
Write-Host "=== VS Code Fast + Privacy Setup ===" -ForegroundColor Cyan

# 1. Copy user configs
$codeUser = Join-Path $env:APPDATA "Code\User"
New-Item -ItemType Directory -Force $codeUser | Out-Null
Copy-Item (Join-Path $here "settings.json") $codeUser -Force
Copy-Item (Join-Path $here "keybindings.json") $codeUser -Force
Write-Host "[OK] settings.json + keybindings.json installed"

# 2. run_c.bat into a tools folder, added to user PATH (works from any project)
$tools = Join-Path $env:LOCALAPPDATA "VSCodeFastTools"
New-Item -ItemType Directory -Force $tools | Out-Null
Copy-Item (Join-Path $here "run_c.bat") $tools -Force
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ([string]::IsNullOrEmpty($userPath)) { $userPath = $tools }
elseif ($userPath -notlike "*$tools*") { $userPath = "$userPath;$tools" }
[Environment]::SetEnvironmentVariable("Path", $userPath, "User")
Write-Host "[OK] run_c.bat installed to $tools and added to PATH"

# 3. Extensions (needs VS Code installed first)
$exts = @(
    "esbenp.prettier-vscode",
    "formulahendry.code-runner",
    "pkief.material-icon-theme",
    "formulahendry.auto-rename-tag",
    "ankitcode.firefly"
)
if (Get-Command code -ErrorAction SilentlyContinue) {
    foreach ($e in $exts) {
        code --install-extension $e --force 2>$null | Out-Null
        Write-Host "[OK] extension: $e"
    }
} else {
    Write-Warning "VS Code CLI not found - install VS Code from https://code.visualstudio.com then re-run this script"
}

# 4. Defender exclusions (self-elevate via UAC)
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
    if (Get-Command Get-MpPreference -ErrorAction SilentlyContinue) {
        Write-Host "[..] Requesting admin approval for Defender exclusions (click Yes)..."
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -DefenderOnly" -Wait
        Write-Host "[OK] Defender exclusions applied"
    } else {
        Write-Warning "Windows Defender not available on this system"
    }
} else {
    & "$PSCommandPath" -DefenderOnly
    Write-Host "[OK] Defender exclusions applied"
}

# 5. Software check
Write-Host "`n=== Software check ===" -ForegroundColor Cyan
foreach ($c in @("python", "node")) {
    if (Get-Command $c -ErrorAction SilentlyContinue) { Write-Host "[OK] $c found" }
    else { Write-Warning "$c NOT installed (python: https://www.python.org/downloads)" }
}
if (Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC") {
    Write-Host "[OK] MSVC BuildTools found"
} else {
    Write-Warning "MSVC 2022 BuildTools NOT found - C/C++ compiling needs 'Desktop C++ build tools' from https://visualstudio.microsoft.com/downloads/"
}
Write-Host "`nDone. Restart VS Code to load new settings." -ForegroundColor Green
Read-Host "Press Enter to close"

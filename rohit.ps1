# --- PARAMETER BLOCK ---
# This allows the GUI to pass data directly into the script
param (
    [Parameter(Mandatory=$false)]
    [string]$Author = "Rohit Kr. Mandal",
    [Parameter(Mandatory=$false)]
    [string]$AppName = "Cyber-App"
)

Write-Host "`n [!] Initializing 2026 Elite Scaffolder..." -ForegroundColor Cyan
Write-Host " [!] Author: $Author" -ForegroundColor Magenta
Write-Host " [!] App Name: $AppName" -ForegroundColor Magenta

# 1. Path & Name Safety
$appNameClean = $AppName -replace '[\s]+', '-'
$cleanName = ($appNameClean -replace '-', '').ToLower()
$projectPath = Join-Path (Get-Location).Path $appNameClean

if (Test-Path $projectPath) {
    Write-Host "`n [!] Cleaning existing directory..." -ForegroundColor Yellow
    Remove-Item -Path $projectPath -Recurse -Force
}

# 2. Directory Structure
New-Item -Path "$projectPath/src" -ItemType Directory -Force | Out-Null
New-Item -Path "$projectPath/src-tauri/src" -ItemType Directory -Force | Out-Null
New-Item -Path "$projectPath/src-tauri/icons" -ItemType Directory -Force | Out-Null

$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

# 3. AUTO-DOWNLOAD WebView2Loader.dll
Write-Host "`n [*] Downloading WebView2Loader.dll..." -ForegroundColor Cyan
$dllUrl = "https://github.com/Rohit5984/VS-Code-/releases/download/v2.0.0/WebView2Loader.dll"
$dllDest = "$projectPath/src-tauri/WebView2Loader.dll"

try {
    Invoke-WebRequest -Uri $dllUrl -OutFile $dllDest -ErrorAction Stop
    Write-Host " [OK] Integrated WebView2Loader.dll" -ForegroundColor Green
} catch {
    Write-Host " [ERROR] Connection failed. DLL missing." -ForegroundColor Red
}

# 4. CONFIG GENERATION (Cargo.toml)
$cargoToml = @"
[package]
name = "$cleanName"
version = "0.1.0"
authors = ["$Author"]
edition = "2021"

[lib]
name = "${cleanName}_lib"
crate-type = ["rlib"]

[dependencies]
tauri = { version = "2", features = [] }
tauri-plugin-shell = "2"
serde = { version = "1", features = ["derive"] }
serde_json = "1"

[build-dependencies]
tauri-build = { version = "2" }

[profile.release]
opt-level = "s"
lto = "thin"
codegen-units = 16
strip = true
"@
[System.IO.File]::WriteAllText("$projectPath/src-tauri/Cargo.toml", $cargoToml, $Utf8NoBom)

# 5. TAURI CONFIG (Glassmorphism Enabled)
$tauriConf = @"
{
  "productName": "$AppName",
  "version": "0.1.0",
  "identifier": "com.$cleanName.dev",
  "build": {
    "beforeDevCommand": "npm run dev",
    "beforeBuildCommand": "npm run build",
    "devUrl": "http://localhost:1420",
    "frontendDist": "../dist"
  },
  "app": {
    "windows": [
      {
        "title": "$AppName",
        "width": 800,
        "height": 600,
        "resizable": true,
        "transparent": true,
        "decorations": true
      }
    ],
    "security": { "csp": null }
  },
  "bundle": {
    "active": true,
    "targets": "all",
    "resources": ["WebView2Loader.dll"]
  }
}
"@
[System.IO.File]::WriteAllText("$projectPath/src-tauri/tauri.conf.json", $tauriConf, $Utf8NoBom)

# 6. PACKAGE.JSON (Signals & Vite 2026)
$packageJson = @"
{
  "name": "$cleanName",
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "tauri": "tauri",
    "desktop": "tauri dev"
  },
  "dependencies": {
    "@preact/signals-core": "^1.8.0",
    "@tauri-apps/api": "^2",
    "@tauri-apps/plugin-shell": "^2"
  },
  "devDependencies": {
    "@tauri-apps/cli": "^2",
    "vite": "^6"
  }
}
"@
[System.IO.File]::WriteAllText("$projectPath/package.json", $packageJson, $Utf8NoBom)

# 7. RUST SOURCE
$rustMain = "fn main() { ${cleanName}_lib::run(); }"
[System.IO.File]::WriteAllText("$projectPath/src-tauri/src/main.rs", $rustMain, $Utf8NoBom)

$rustLib = @"
#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
"@
[System.IO.File]::WriteAllText("$projectPath/src-tauri/src/lib.rs", $rustLib, $Utf8NoBom)

$buildRs = "fn main() { tauri_build::build(); }"
[System.IO.File]::WriteAllText("$projectPath/src-tauri/build.rs", $buildRs, $Utf8NoBom)

Write-Host "`n [SUCCESS] Project '$AppName' created by $Author." -ForegroundColor Green
Write-Host " [TIP] Run 'npm install' then 'npm run desktop' to start." -ForegroundColor Cyan

# Keep window open for debugging if needed
if ($Host.Name -eq "ConsoleHost") { Read-Host "`nPress Enter to exit" }

# architect.ps1
function Build-WinRazeProject {
    param (
        [Parameter(Mandatory=$true)] [string]$authorName,
        [Parameter(Mandatory=$true)] [string]$appNameRaw,
        [switch]$installMsys,
        [switch]$installRust,
        [switch]$installNode
    )

    # 1. Path & Name Safety
    $appName   = $appNameRaw -replace '[\s]+', '-'
    $cleanName = ($appName -replace '-', '').ToLower()
    $projectPath = Join-Path (Get-Location).Path $appName

    Write-Host "`n[!] Initializing WinRaze Architecture for: $appNameRaw" -ForegroundColor Cyan

    # 2. Check for existing folder
    if (Test-Path $projectPath) {
        Write-Host "[!] Warning: Folder '$appName' already exists. Cleaning up..." -ForegroundColor Yellow
        Remove-Item -Path $projectPath -Recurse -Force
    }

    # 3. CRITICAL: Create Directory Structure first
    Write-Host "[*] Creating directory structure..." -ForegroundColor Gray
    New-Item -Path "$projectPath/src" -ItemType Directory -Force | Out-Null
    New-Item -Path "$projectPath/src-tauri/src" -ItemType Directory -Force | Out-Null
    New-Item -Path "$projectPath/src-tauri/icons" -ItemType Directory -Force | Out-Null

    $Utf8NoBom = New-Object System.Text.UTF8Encoding $false

    # 4. AUTO-DOWNLOAD WebView2Loader.dll
    Write-Host "[*] Fetching WebView2Loader.dll..." -ForegroundColor Cyan
    $dllUrl = "https://github.com/Rohit5984/VS-Code-/releases/download/v2.0.0/WebView2Loader.dll"
    $dllDest = "$projectPath/src-tauri/WebView2Loader.dll"

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $dllUrl -OutFile $dllDest -ErrorAction Stop
        Write-Host "[SUCCESS] WebView2Loader.dll integrated." -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Internet connection required for DLL download." -ForegroundColor Red
    }

    # 5. Writing Architecture Files
    Write-Host "[*] Injecting Cargo, Tauri, and Vite configs..." -ForegroundColor Gray

    # --- Cargo.toml ---
    $cargoToml = @"
[package]
name = "$cleanName"
version = "0.1.0"
authors = ["$authorName"]
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

    # --- Tauri Config ---
    $safeAuthorId = $authorName.ToLower() -replace ' ',''
    $tauriConf = @"
{
  "productName": "$appNameRaw",
  "version": "0.1.0",
  "identifier": "com.$cleanName.dev.$safeAuthorId",
  "build": {
    "beforeDevCommand": "npm run dev",
    "beforeBuildCommand": "npm run build",
    "devUrl": "http://localhost:1420",
    "frontendDist": "../dist"
  },
  "app": {
    "windows": [
      {
        "title": "$appNameRaw",
        "width": 400,
        "height": 600,
        "resizable": false,
        "transparent": true,
        "decorations": true
      }
    ],
    "security": { "csp": null }
  },
  "bundle": {
    "active": true,
    "targets": "all",
    "icon": ["icons/hot.ico"],
    "resources": ["WebView2Loader.dll"]
  }
}
"@
    [System.IO.File]::WriteAllText("$projectPath/src-tauri/tauri.conf.json", $tauriConf, $Utf8NoBom)

    # --- Rust & Web Files ---
    [System.IO.File]::WriteAllText("$projectPath/src-tauri/src/main.rs", "#![cfg_attr(not(debug_assertions), windows_subsystem = \"windows\")]`nfn main() { ${cleanName}_lib::run(); }", $Utf8NoBom)
    
    $rustLib = "   #[cfg_attr(mobile, tauri::mobile_entry_point)]`npub fn run() {`n    tauri::Builder::default().plugin(tauri_plugin_shell::init()).run(tauri::generate_context!()).expect(`"error`");`n}"
    [System.IO.File]::WriteAllText("$projectPath/src-tauri/src/lib.rs", $rustLib, $Utf8NoBom)

    [System.IO.File]::WriteAllText("$projectPath/package.json", "{`"name`":`"$cleanName`",`"version`":`"0.1.0`",`"type`":`"module`",`"scripts`":{`"dev`":`"vite`",`"build`":`"vite build`",`"desktop`":`"tauri dev`"}} ", $Utf8NoBom)
    
    [System.IO.File]::WriteAllText("$projectPath/index.html", "<!DOCTYPE html><html><head><title>$appNameRaw</title></head><body><div id='root'></div><script type='module' src='/src/main.js'></script></body></html>", $Utf8NoBom)
    [System.IO.File]::WriteAllText("$projectPath/src/main.js", "// Logic starts here", $Utf8NoBom)
    [System.IO.File]::WriteAllText("$projectPath/src/style.css", "/* Styles start here */", $Utf8NoBom)
    [System.IO.File]::WriteAllText("$projectPath/.gitignore", "node_modules`ndist`ntarget`n*.log", $Utf8NoBom)
    [System.IO.File]::WriteAllText("$projectPath/src-tauri/build.rs", "fn main() { tauri_build::build(); }", $Utf8NoBom)

    # 6. Tools Setup
    $desktop = [Environment]::GetFolderPath("Desktop")
    $toolsFolder = "$desktop\WinRaze_Tools"
    if (!(Test-Path $toolsFolder)) { New-Item -ItemType Directory -Path $toolsFolder | Out-Null }

    # Define tool download helper
    $downloadTool = {
        param($url, $name)
        $path = Join-Path $toolsFolder $name
        Write-Host "[*] Downloading $name..." -ForegroundColor Yellow
        try { Invoke-WebRequest -Uri $url -OutFile $path -ErrorAction Stop; Write-Host "[SUCCESS] $name saved to Desktop." -ForegroundColor Green }
        catch { Write-Host "[FAILED] Could not download $name." -ForegroundColor Red }
    }

    if ($installMsys) { &$downloadTool "https://github.com/Rohit5984/Software/releases/download/v1.0.0/Msys2-x86_64-20251213.exe" "Msys2-Installer.exe" }
    if ($installRust) { &$downloadTool "https://github.com/Rohit5984/Software/releases/download/v1.0.0/rustup-init.exe" "rustup-init.exe" }
    if ($installNode) { &$downloadTool "https://github.com/Rohit5984/Software/releases/download/v1.0.0/Node-v24.14.0-x64.msi" "Node-Installer.msi" }

    Write-Host "`n[S-RANK COMPLETE] Project created at: $projectPath" -ForegroundColor Green
    Write-Host "[!] To start: cd $appName; npm install; npm run desktop" -ForegroundColor Cyan
}
# --------------------------------------------------------------------------------
# Script: project_setup.ps1
# Author: Rohit Kr.Mandal
# Description: Automates the setup of HTML/CSS/JS, React, or React+Electron projects
#              with a GUI folder picker for destination and source paths.
# --------------------------------------------------------------------------------

# Check for Administrator Privileges
Write-Output "Checking for Administrator Privileges..."
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "Please run this script as an Administrator."
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Bypass execution policy temporarily
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Show Author Name
Write-Host "Script Author: Rohit Kr.Mandal" -ForegroundColor Green

# Display Project Menu
Write-Host "`nChoose your project type:" -ForegroundColor Cyan
Write-Host "1) HTML/CSS/JS"
Write-Host "2) React JS (Online)"
Write-Host "3) None"
Write-Host "4) React JS (Offline)"

# User Input
$projectType = Read-Host "Enter your choice (1, 2, 3, or 4)"
$basePath = "C:\"

# Function to test internet connection
function Test-InternetConnection {
    try {
        $response = Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing -TimeoutSec 5
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

# Function to check for VS Code CLI
function Check-CodeCLI {
    if (-not (Get-Command "code" -ErrorAction SilentlyContinue)) {
        Write-Host "VS Code CLI not found. Run 'Shell Command: Install 'code' command in PATH' from VS Code." -ForegroundColor Red
        Exit
    }
}

# Function to select folder using GUI
function Select-Folder {
    param(
        [string]$Description = "Select a folder",
        [string]$InitialPath = $null,
        [bool]$AllowNewFolder = $true
    )

    try {
        if ([System.Threading.Thread]::CurrentThread.ApartmentState -eq 'STA') {
            Add-Type -AssemblyName System.Windows.Forms | Out-Null
            $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $dialog.Description = $Description
            $dialog.ShowNewFolderButton = $AllowNewFolder
            if ($InitialPath -and (Test-Path $InitialPath)) { $dialog.SelectedPath = $InitialPath }

            $result = $dialog.ShowDialog()
            if ($result -eq [System.Windows.Forms.DialogResult]::OK -and (Test-Path $dialog.SelectedPath)) {
                return $dialog.SelectedPath
            }
            return $null
        }
    } catch {
        # Fallback to COM-based picker if Forms fails
    }

    try {
        $shell = New-Object -ComObject Shell.Application
        $root = if ($InitialPath -and (Test-Path $InitialPath)) { $InitialPath } else { 0 }
        $folder = $shell.BrowseForFolder(0, $Description, 0x11, $root)
        if ($folder) {
            $path = $folder.Self.Path
            if (Test-Path $path) { return $path }
        }
    } catch {
        # Ignore errors
    }

    return $null
}

switch ($projectType) {
    "1" {
        Write-Host "Setting up HTML/CSS/JS project..." -ForegroundColor Cyan
        $folderName = Read-Host "Name your HTML/CSS/JS project folder"
        
        # GUI picker for destination base path
        $destBase = Select-Folder -Description "Pick the destination base path (Cancel to use $basePath)" -InitialPath $basePath -AllowNewFolder $true
        $basePathInput = if ($destBase) { $destBase } else { $basePath }

        $projectPath = Join-Path $basePathInput $folderName
        New-Item -Path $projectPath -ItemType Directory -Force | Out-Null
        Write-Host "Folder ready at: $projectPath" -ForegroundColor Green

        @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Project</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
</body>
<script src="script.js"></script>
</html>
"@ | Set-Content "$projectPath\index.html" -Encoding UTF8

        New-Item -Path "$projectPath\style.css" -ItemType File -Force | Out-Null
        New-Item -Path "$projectPath\script.js" -ItemType File -Force | Out-Null
        Write-Host "Created index.html, style.css, and script.js" -ForegroundColor Green

        Check-CodeCLI
        Start-Process code -ArgumentList "`"$projectPath`""
    }

    "2" {
        Write-Host "Setting up React project (Online)..." -ForegroundColor Cyan
        $folderName = Read-Host "Name your React project folder"
        
        # GUI picker for destination base path
        $destBase = Select-Folder -Description "Pick the destination base path (Cancel to use $basePath)" -InitialPath $basePath -AllowNewFolder $true
        $basePathInput = if ($destBase) { $destBase } else { $basePath }

        $projectPath = Join-Path $basePathInput $folderName
        New-Item -Path $projectPath -ItemType Directory -Force | Out-Null
        Write-Host "Folder ready at: $projectPath" -ForegroundColor Green

        Write-Output "Checking Internet Connection..."
        $online = Test-InternetConnection

        if (-not $online) {
            Write-Host "No internet connection detected. Cannot create React app online. Aborting." -ForegroundColor Red
            return
        }

        Write-Host "Internet detected. Checking npm version..." -ForegroundColor Green
        $currentVersion = npm -v
        $latestVersion = (Invoke-RestMethod -Uri "https://registry.npmjs.org/npm/latest").version
        Write-Output "Current npm version: $currentVersion"
        Write-Output "Latest available version: $latestVersion"

        if ($currentVersion -ne $latestVersion) {
            $updateChoice = Read-Host "Do you want to update npm to the latest version? (y/n)"
            if ($updateChoice -match '^[Yy]') {
                Start-Process powershell -ArgumentList "-Command npm install -g npm@latest" -Verb RunAs
                Write-Host "npm update initiated..." -ForegroundColor Yellow
                Start-Sleep -Seconds 10
            } else {
                Write-Host "Skipping npm update." -ForegroundColor Yellow
            }
        } else {
            Write-Host "npm is already up to date!" -ForegroundColor Green
        }

        Write-Host "Visit https://nodejs.org to manually update Node.js if needed." -ForegroundColor Yellow

        $reactAppName = Read-Host "Enter a name for your React app"
        Set-Location -Path $projectPath
        npx create-react-app $reactAppName

        $fullAppPath = Join-Path $projectPath $reactAppName
        if (Test-Path $fullAppPath) {
            Check-CodeCLI
            Start-Process code -ArgumentList "`"$fullAppPath`""
            Write-Host "React app '$reactAppName' created and opened in VS Code." -ForegroundColor Green
        } else {
            Write-Host "Failed to create React app. Check Node.js and npm setup." -ForegroundColor Red
        }
    }

    "3" {
        Write-Host "Skipping project creation. Proceeding with VS Code setup..." -ForegroundColor Yellow
    }

    "4" {
        Write-Host "Setting up React + Electron project (Offline)..." -ForegroundColor Cyan
        $folderName = Read-Host "Name your React project folder"
        
        # GUI picker for destination base path
        $destBase = Select-Folder -Description "Pick the destination base path (Cancel to use $basePath)" -InitialPath $basePath -AllowNewFolder $true
        $basePathInput = if ($destBase) { $destBase } else { $basePath }

        $projectPath = Join-Path $basePathInput $folderName
        try {
            New-Item -Path $projectPath -ItemType Directory -Force | Out-Null
            Write-Host "Folder ready at: $projectPath" -ForegroundColor Green 
        } catch {
            Write-Host "Error creating project folder: $_" -ForegroundColor Red
            Write-Host "Press any key to continue..." -ForegroundColor Yellow
            $null = Read-Host
            return
        }

        Write-Host "Select your React files/folder (from a drive or USB)" -ForegroundColor Red

        # GUI picker for source folder
        $sourcePath = Select-Folder -Description "Pick the source folder to copy from" -InitialPath $basePathInput -AllowNewFolder $false
        if (-not $sourcePath) {
            Write-Host "No folder selected. Aborting." -ForegroundColor Red
            Write-Host "Press any key to continue..." -ForegroundColor Yellow
            $null = Read-Host
            return
        }
        Write-Host "React files/folder selected: $sourcePath" -ForegroundColor Green

        try {
            $items = Get-ChildItem -Path $sourcePath -Recurse -Force
            $total = $items.Count
            $count = 0

            foreach ($item in $items) {
                $count++
                $target = $item.FullName.Replace($sourcePath, $projectPath)
                if ($item.PSIsContainer) {
                    if (-not (Test-Path $target)) {
                        New-Item -ItemType Directory -Path $target -Force | Out-Null
                    }
                } else {
                    Copy-Item -Path $item.FullName -Destination $target -Force
                }
                $percent = if ($total -gt 0) { [math]::Round(($count / $total) * 100, 2) } else { 100 }
                Write-Progress -Activity "Copying files..." -Status "$count of $total ($percent%)" -PercentComplete $percent
            }

            Write-Progress -Activity "Copying files..." -Completed
            Write-Host "Copy complete." -ForegroundColor Green
        } catch {
            Write-Host "Error during file copying: $_" -ForegroundColor Red
            Write-Host "Press any key to continue..." -ForegroundColor Yellow
            $null = Read-Host
            return
        }

        # Open File Explorer and pause to keep the window open
        try {
            Start-Process explorer.exe -ArgumentList "`"$projectPath`""
            Write-Host "File Explorer opened at: $projectPath" -ForegroundColor Green
            Write-Host "Press any key to continue..." -ForegroundColor Yellow
            $null = Read-Host  # More reliable than Pause in some contexts
        } catch {
            Write-Host "Error opening File Explorer: $_" -ForegroundColor Red
            Write-Host "Press any key to continue..." -ForegroundColor Yellow
            $null = Read-Host
        }

        try {
            $required = @("node_modules", "public", "src", "package.json", "README.md")
            $missing = $required | Where-Object { -not (Test-Path (Join-Path $projectPath $_)) }

            if ($missing.Count -gt 0) {
                Write-Host "The following required items are missing:" -ForegroundColor Red
                $missing | ForEach-Object { Write-Host "   - $_" -ForegroundColor Red }
                Write-Host "Skipping VS Code launch." -ForegroundColor Yellow
            } else {
                Check-CodeCLI
                Start-Process code -ArgumentList "`"$projectPath`""
                Write-Host "Project opened in VS Code." -ForegroundColor Green

                if (Test-InternetConnection) {
                    Write-Host "Internet connection detected." -ForegroundColor Green
                    $currentVersion = npm -v
                    Write-Host "Current npm version: $currentVersion"
                    try {
                        $latestVersion = (Invoke-RestMethod -Uri "https://registry.npmjs.org/npm/latest").version
                        Write-Host "Latest npm version: $latestVersion"
                    } catch {
                        Write-Host "Unable to fetch latest npm version." -ForegroundColor Yellow
                        $latestVersion = $null
                    }

                    if ($latestVersion -and $currentVersion -ne $latestVersion) {
                        $updateChoice = Read-Host "Do you want to update npm globally? (y/n)"
                        if ($updateChoice -match '^[Yy]') {
                            Start-Process powershell -ArgumentList "-Command npm install -g npm@latest" -Verb RunAs
                            Write-Host "npm update initiated to version $latestVersion." -ForegroundColor Yellow
                        } else {
                            Write-Host "Skipping npm update." -ForegroundColor Yellow
                        }
                    } else {
                        Write-Host "npm is already up to date or check skipped." -ForegroundColor Green
                    }
                } else {
                    Write-Host "Offline mode: Skipping npm update." -ForegroundColor Yellow
                }
            }
        } catch {
            Write-Host "Error during post-copy operations: $_" -ForegroundColor Red
            Write-Host "Press any key to continue..." -ForegroundColor Yellow
            $null = Read-Host
        }
    }

    default {
        Write-Host "Invalid choice. Please run the script again and select a valid option." -ForegroundColor Red
        Write-Host "Press any key to continue..." -ForegroundColor Yellow
        $null = Read-Host
    }
}


# --- Ask user which extensions to install ---
$extensionChoice = Read-Host "Choose extensions to install:`n1. Live Server`n2. React Snippets`n3. Firefly + Auto Rename + Prettier`n4. None"

switch ($extensionChoice) {
    "1" {
        code --install-extension ritwickdey.LiveServer
        Write-Output "✅ Installed: Live Server"
    }
    "2" {
        code --install-extension dsznajder.es7-react-js-snippets
        Write-Output "✅ Installed: React JS Snippets"
    }
    "3" {
        code --install-extension ankitcode.firefly
        code --install-extension formulahendry.auto-rename-tag
        code --install-extension esbenp.prettier-vscode
        Write-Output "✅ Installed: Firefly, Auto Rename Tag, Prettier"
    } 
    "4" {
        Write-Output "⚠️ No extensions installed."
    }
    default {
        Write-Output "⚠️ Invalid option. No extensions installed."
    }
}

# --- Ask before applying global VS Code settings ---
$answer = Read-Host "Do you want to set Fira Code font and Prettier as your default VS Code formatter and font? (Y/N)"
if ($answer.ToLower() -eq 'y') {

  # --- Ensure Global VS Code Settings for Prettier & FiraCode ---
  $globalSettingsPath    = "$env:APPDATA\Code\User\settings.json"
  $desiredGlobalSettings = @{
    "editor.defaultFormatter" = "esbenp.prettier-vscode"
    "editor.formatOnSave"     = $true
    "editor.fontFamily"       = "Fira Code, 'Courier New', monospace"
    "editor.fontLigatures"    = $true
  }

  if (Test-Path $globalSettingsPath) {
    try {
      $existingJson = Get-Content $globalSettingsPath -Raw | ConvertFrom-Json
      if (-not ($existingJson -is [hashtable])) { $existingJson = @{} }
    } catch {
      $existingJson = @{}
    }
  } else {
    # Create parent folder and initialize file
    $parent = Split-Path $globalSettingsPath
    New-Item -Path $parent -ItemType Directory -Force | Out-Null
    '{}' | Out-File -FilePath $globalSettingsPath -Encoding UTF8
    $existingJson = @{}
  }

  $updated = $false
  foreach ($key in $desiredGlobalSettings.Keys) {
    if (-not $existingJson.ContainsKey($key) -or
        $existingJson[$key] -ne $desiredGlobalSettings[$key]) {
      $existingJson[$key] = $desiredGlobalSettings[$key]
      $updated = $true
    }
  }

  if ($updated) {
    $existingJson |
      ConvertTo-Json -Depth 10 |
      Set-Content -Path $globalSettingsPath -Encoding UTF8
    Write-Output "✅ Global settings updated with Prettier & FiraCode font."
  } else {
    Write-Output "✅ Global settings already include Prettier & FiraCode font."
  }

} else {
  Write-Output "⚠️ Skipping global VS Code settings for Prettier & FiraCode."
}

Pause

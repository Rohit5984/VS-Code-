# --- Check for Administrator Privileges ---
Write-Output "--- Checking for Administrator Privileges ---"
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "Please run this script as an Administrator."
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# --- Bypass execution policy temporarily ---
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# --- Show Author Name ---
Write-Host "Script Author: Rohit Kr.Mandal"

# --- Display Project Menu ---
Write-Host "Choose your project type:"
Write-Host "1) HTML/CSS/JS"
Write-Host "2) React (Online)"
Write-Host "3) None"
Write-Host "4) React (Offline)"

# --- User Input ---
$projectType = Read-Host "Enter your choice (1, 2, 3 or 4)"
$projectPath = $null
$basePath = "C:\"  # Define base path

function Test-InternetConnection {
    try {
        $response = Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing -TimeoutSec 5
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

function Check-CodeCLI {
    if (-not (Get-Command "code" -ErrorAction SilentlyContinue)) {
        Write-Host "❌ VS Code command line tools not found. Please run 'Shell Command: Install 'code' command in PATH' from VS Code."
        Exit
    }
}

switch ($projectType) {
    "1" {
        $folderName = Read-Host "Name your HTML/CSS/Js project folder"
        $projectPath = "C:\$folderName"

        New-Item -Path $projectPath -ItemType Directory -Force
        Write-Output "Folder '$folderName' created at $projectPath"

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
"@ | Set-Content "$projectPath\index.html"

        New-Item -Path "$projectPath\style.css" -ItemType File -Force
        New-Item -Path "$projectPath\script.js" -ItemType File -Force
        Write-Output "Created index.html, style.css, and script.js"

        Start-Process code -ArgumentList "`"$projectPath`""
    }

    "2" {
        $folderName = Read-Host "Name your React project folder"
        $projectPath = "C:\$folderName"

        New-Item -Path $projectPath -ItemType Directory -Force
        Write-Output "Folder '$folderName' created at $projectPath"

      Write-Output "--- Checking Internet Connection ---"
$online = Test-InternetConnection

if ($online) {
    Write-Output "Internet detected. Checking npm version..."

    $currentVersion = npm -v
    $latestVersion = npm view npm version

    Write-Output "Current npm version: $currentVersion"
    Write-Output "Latest available version: $latestVersion"

    if ($currentVersion -ne $latestVersion) {
        $updateChoice = Read-Host "Do you want to update to the latest version? (y/n)"
        if ($updateChoice -eq "y") {
            Start-Process powershell -ArgumentList "-Command npm install -g npm@latest" -Verb RunAs
            Write-Output "npm is being updated..."
        } else {
            Write-Output "Skipping npm update."
        }
    } else {
        Write-Output "npm is already up to date!"
    }

    Write-Output "Visit https://nodejs.org to manually update Node.js if needed."
} else {
    Write-Output "Offline mode: Skipping update check."
}


        $reactAppName = Read-Host "Enter a name for your React app"
        Set-Location -Path $projectPath
        npx create-react-app $reactAppName

        $fullAppPath = Join-Path $projectPath $reactAppName
        if (Test-Path $fullAppPath) {
            Start-Process code -ArgumentList "`"$fullAppPath`""
            Write-Output "✅ React app '$reactAppName' created and opened in VS Code."
        } else {
            Write-Output "❌ Failed to create React app. Check Node.js and npm setup."
        }
    }

    "3" {
        Write-Output "Skipping project creation. Proceeding with VS Code setup..."
    }

    "4" {
        $folderName  = Read-Host "Enter the name of your existing React project folder"
        $projectPath = Join-Path $basePath $folderName
        New-Item -Path $projectPath -ItemType Directory -Force | Out-Null

        Write-Host "Copy your React project files into: $projectPath"
        Read-Host "Press Enter when ready to continue..."

        $required = @("node_modules","public","src","package.json","README.md")
        $missing  = $required | Where-Object {
            -not (Test-Path (Join-Path $projectPath $_))
        }

        if ($missing.Count -gt 0) {
            Write-Host "Sorry Dear, the following required items are missing:"
            $missing | ForEach-Object { Write-Host "   - $_" }
            Write-Host "We’ll skip this step and move on to the next section."
        } else {
            Check-CodeCLI
            Start-Process code -ArgumentList "`"$projectPath`""
            Write-Host "✅ Project opened in VS Code."

           if (Test-InternetConnection) {
    Write-Host "✅ Internet connection detected."

    # Check current npm version
    $currentVersion = npm -v
    Write-Host "Current npm version installed: $currentVersion"

    # Fetch latest version from npm registry
    try {
        $latestVersion = Invoke-RestMethod -Uri "https://registry.npmjs.org/npm/latest" |
                         Select-Object -ExpandProperty version
        Write-Host "Latest available npm version:  $latestVersion"
    } catch {
        Write-Host "⚠️ Unable to fetch latest npm version."
        $latestVersion = $null
    }

    $updateChoice = Read-Host "Do you want to update npm globally to the latest version? (y/n)"
    if ($updateChoice -match '^[Yy]' -and $latestVersion) {
        Start-Process powershell -ArgumentList "-Command npm install -g npm@latest" -Verb RunAs
        Write-Host "🔄 npm update initiated to version $latestVersion."
    } else {
        Write-Host "⏩ Skipping npm update."
    }
} else {
    Write-Host "⚠️ Offline mode: Skipping version check and update."
}

        }
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

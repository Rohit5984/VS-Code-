# --- Check for Administrator Privileges ---
Write-Output "--- Checking for Administrator Privileges ---"
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "Please run this script as an Administrator."
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# --- Bypass execution policy temporarily ---
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# --- Display Project Menu ---
Write-Host "Choose your project type:"
Write-Host "1) HTML/CSS/JS"
Write-Host "2) React"
Write-Host "3) None"

# --- User Input ---
$projectType = Read-Host "Enter your choice (1, 2, or 3)=>"
$projectPath = $null

switch ($projectType) {
    "1" {
        # --- Prompt user for folder name ---
        $folderName = Read-Host "Enter the name for your project folder"
        $projectPath = "C:\$folderName"

        # --- Create the folder ---
        New-Item -Path $projectPath -ItemType Directory -Force
        Write-Output "Folder '$folderName' created at $projectPath"

        # HTML/CSS/JS setup
        New-Item -Path "$projectPath\index.html" -ItemType File -Force
        New-Item -Path "$projectPath\style.css" -ItemType File -Force
        New-Item -Path "$projectPath\script.js" -ItemType File -Force
        Write-Output "Created index.html, style.css, and script.js"
        Start-Process code -ArgumentList "`"$projectPath`""
    }

    "2" {
        # --- Prompt user for folder name ---
        $folderName = Read-Host "Enter the name for your project folder"
        $projectPath = "C:\$folderName"

        # --- Create the folder ---
        New-Item -Path $projectPath -ItemType Directory -Force
        Write-Output "Folder '$folderName' created at $projectPath"

        Write-Output "--- Checking Internet Connection ---"
        try {
            $response = Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing -TimeoutSec 5
            $online = $response.StatusCode -eq 200
        } catch {
            $online = $false
        }

        if ($online) {
            $updateChoice = Read-Host "Internet detected. Update npm to latest version? (y/n)"
            if ($updateChoice -eq "y") {
                Start-Process powershell -ArgumentList "-Command npm install -g npm@latest" -Verb RunAs
                Write-Output "Visit https://nodejs.org to manually update Node.js if needed."
            } else {
                Write-Output "Skipping npm update..."
            }
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
        # Proceed to extension install or font config
    }

    default {
        Write-Output "❌ Invalid project type. Only '1', '2', or '3' accepted."
        Exit
    }
}

# --- Ask user which extensions to install ---
$extensionChoice = Read-Host "Choose extensions to install:`n1. Live Server`n2. React Snippets`n3. Firefly + Auto Rename + Prettier + Bracket Color`n4. None"

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

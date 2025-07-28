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
        code --install-extension CoenraadS.bracket-pair-color-dlw
        Write-Output "✅ Installed: Firefly, Auto Rename Tag, Prettier, Bracket Pair Color"
    } 
    "4" {
        Write-Output "⚠️ No extensions installed."
    }
    default {
        Write-Output "⚠️ Invalid option. No extensions installed."
    }
}
# --- Set VS Code settings path ---
$settingsPath = "$env:APPDATA\Code\User\settings.json"
Write-Output "🛠️ Updating VS Code settings for Prettier..."

# --- Define Prettier Settings Content ---
$settingsContent = @"
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true
}
"@

# --- Ensure settings.json exists and merge settings safely ---
if (Test-Path $settingsPath) {
    try {
        $existingContent = Get-Content $settingsPath -Raw
        $existingJson = $existingContent | ConvertFrom-Json
        $existingJson["editor.defaultFormatter"] = "esbenp.prettier-vscode"
        $existingJson["editor.formatOnSave"] = $true
        $mergedJson = $existingJson | ConvertTo-Json -Depth 10
        Set-Content -Path $settingsPath -Value $mergedJson -Encoding UTF8
        Write-Output "✅ Prettier settings merged into existing settings.json"
    } catch {
        Write-Output "⚠️ Could not parse existing settings.json. Overwriting with Prettier settings only."
        Set-Content -Path $settingsPath -Value $settingsContent -Encoding UTF8
    }
} else {
    # Create new settings.json with Prettier config
    New-Item -Path $settingsPath -ItemType File -Force | Out-Null
    Set-Content -Path $settingsPath -Value $settingsContent -Encoding UTF8
    Write-Output "✅ Created new settings.json with Prettier config"
}

# --- Ask to generate .prettierrc file ---
$addPrettierConfig = Read-Host "Do you want to add a basic .prettierrc file to your project? (y/n)"
if ($addPrettierConfig -eq "y") {
    # Make sure $projectPath is defined
    if (-not $projectPath) {
        $projectPath = Read-Host "Enter your project folder path (e.g., C:\MyProject)"
    }

    $configPath = Join-Path $projectPath ".prettierrc"
    $configContent = @"
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2
}
"@
    Set-Content -Path $configPath -Value $configContent -Encoding UTF8
    Write-Output "✅ Created .prettierrc file in '$projectPath'"
}

# --- VS Code Font Configuration Prompt ---
$settingsPath = "$env:APPDATA\Code\User\settings.json"

# --- Ask User for Confirmation ---
$useFiraCode = Read-Host "Do you want to set FiraCode-Medium as your default font in VS Code? (y/n)"

if ($useFiraCode -eq "y") {
    Write-Output "🖋️ Applying FiraCode-Medium font configuration..."

    # --- Desired Settings ---
    $fontSettings = @{
        "editor.fontFamily"    = "fira code, 'Courier New', monospace"
        "editor.fontLigatures" = $true
    }

    # --- Update or Create settings.json ---
    if (Test-Path $settingsPath) {
        try {
            $existingContent = Get-Content $settingsPath -Raw
            $existingJson = $existingContent | ConvertFrom-Json
            foreach ($key in $fontSettings.Keys) {
                $existingJson[$key] = $fontSettings[$key]
            }
            $mergedJson = $existingJson | ConvertTo-Json -Depth 10
            Set-Content -Path $settingsPath -Value $mergedJson -Encoding UTF8
            Write-Output "✅ FiraCode-Medium font settings updated in settings.json"
        } catch {
            Write-Output "⚠️ Failed to parse existing settings. Overwriting with new font config."
            $fontJson = $fontSettings | ConvertTo-Json -Depth 10
            Set-Content -Path $settingsPath -Value $fontJson -Encoding UTF8
        }
    } else {
        # Create new settings.json with font settings
        New-Item -Path $settingsPath -ItemType File -Force | Out-Null
        $fontJson = $fontSettings | ConvertTo-Json -Depth 10
        Set-Content -Path $settingsPath -Value $fontJson -Encoding UTF8
        Write-Output "✅ Created settings.json with FiraCode-Medium font settings"
    }
} else {
    Write-Output "⚠️ Skipped font configuration. FiraCode-Medium was not set as default."
}

Write-Output "🎉 Font setup decision complete!"


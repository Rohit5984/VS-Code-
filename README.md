🚀 Universal Software Installer

A simple PowerShell script that automatically installs all .exe and .msi software inside a folder.

📁 How to Use
1️⃣ Create a Folder

Create a folder with any name you like.

For example:

Software

2️⃣ Add Your Software

Put all the software installers you want to install inside the folder.

Software/
├── Chrome.exe
├── VLC.exe
├── 7zip.exe
├── Discord.exe
├── Office.msi
└── install.ps1

3️⃣ Add the PowerShell Script

Copy install.ps1 into the same folder as your software installers.

4️⃣ Run the Script ▶️

Right-click install.ps1 and select Run with PowerShell.

The script will automatically find all .exe and .msi files in the folder and install them.

⚙️ What It Does
🔍 Automatically detects .exe and .msi files
🤫 Installs software silently
🛡️ Automatically requests Administrator permission
⏱️ Stops installers that take longer than 10 minutes
📝 Creates an install.log file with the installation results
🎉 That's It!

Put your software installers and install.ps1 in the same folder, then run the script.

The script will automatically install the software for you. 🚀

🚀 Universal Software Installer
A simple PowerShell script that automatically installs all .exe and .msi software inside a folder.

📁 How to Use
1️⃣ Create a Folder
Create a folder with any name you like, for example:

📁 Software

2️⃣ Add Your Software
Put all the software installers you want to install inside the folder.

📁 Software
 ├── 🌐 Chrome.exe
 ├── 🎵 VLC.exe
 ├── 🗜️ 7zip.exe
 ├── 💬 Discord.exe
 ├── 📦 Office.msi
 └── ⚡ install.ps1

3️⃣ Add the PowerShell Script
Put install.ps1 inside the same folder with all your software.

4️⃣ Run the Script ▶️
Right-click install.ps1 and select:

Run with PowerShell

5️⃣ Automatic Installation ⚙️
The script will automatically:

🔍 Find all .exe and .msi files
🤫 Install them silently
🛡️ Request Administrator permission if required
⏱️ Prevent installers from running forever
📝 Create an install.log file with the results
🎉 That's It!
Just put your software + install.ps1 in one folder and run the script.

All supported software will be installed automatically. 🚀

📝 Log File
After installation, you can check:

📄 install.log

for the installation results.

# Steps to build a Software

Install MSYS2 and open MSYS2 UCRT64 terminal, then type:
pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain  
Hit enter, it will download all files.

Download Rustup-init.exe (X64), type 2 enter and again press enter,after completing.

After finishing HTML, CSS, JS setup in VS Code terminal, type these:

```powershell
# ===== 1. ENVIRONMENT SETUP (one-time) =====
# MSYS2: Install base-devel, mingw-w64-x86_64-toolchain
# Rust: Use GNU toolchain
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
rustup default stable-x86_64-pc-windows-gnu
rustup target add x86_64-pc-windows-gnu

# Node: Install dependencies
npm install
npm install -D @tauri-apps/cli@latest vite

npm run build-exe
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" innosetup.iss


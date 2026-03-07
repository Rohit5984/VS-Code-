# Setup Guide

Install MSYS2 and open MSYS2 UCRT64 terminal, then type:
pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain  
Hit enter, it will download all files.

Download Rustup-init.exe (X64), type 2 enter and again enter after completing.

After finishing HTML, CSS, JS setup in VS Code terminal, type these:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser  
rustup target add x86_64-pc-windows-gnu  
rustup default stable-x86_64-pc-windows-gnu  
npm install  
npm install -D @tauri-apps/cli@latest  
npm run build-win

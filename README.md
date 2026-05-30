# Setup Guide

Install MSYS2 and open MSYS2 UCRT64 terminal, then type:
pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain  
Hit enter, it will download all files.

Download Rustup-init.exe (X64), type 2 enter and again enter after completing.

After finishing HTML, CSS, JS setup in VS Code terminal, type these:

# 1. Allow running scripts on Windows
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 2. Force Rust to use the Windows GNU toolchain
rustup target add x86_64-pc-windows-gnu
rustup default stable-x86_64-pc-windows-gnu

# 3. Clear frontend distributions (safely skipped if new project)
Remove-Item -Recurse -Force dist, .vite -ErrorAction SilentlyContinue

# 4. Clear local Rust binaries (safely skipped if new project)
if (Test-Path "src-tauri") {
    cd src-tauri
    cargo clean
    Remove-Item -Force Cargo.lock -ErrorAction SilentlyContinue
    cd ..
}

# 5. Clear old node directories (safely skipped if new project)
Remove-Item -Recurse -Force node_modules, package-lock.json -ErrorAction SilentlyContinue

# 6. Fetch all dependencies fresh from the internet
npm install
npm install -D @tauri-apps/cli@latest

# 7. Run the fresh compilation sequence
npm run build-win

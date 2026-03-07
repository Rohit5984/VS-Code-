** MSYS2 Build Toolchain * Purpose: Essential C++ compiler for Rust Windows-GNU targets.

Step: Install MSYS2, then run:
pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain

(Hit Enter, then hit Enter again to download all required files.)

** Rustup-init (X64) * Purpose: The language core for Tauri's backend.
Step: Run the installer and Select Option 2 (Manual). Hit Enter to complete.

** After your HTML, CSS, and JS are ready.
Action: Open VS Code terminal and paste the following:
Set Execution Policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

** Add & Set GNU Target
rustup target add x86_64-pc-windows-gnu
rustup default stable-x86_64-pc-windows-gnu

** Install Node Dependencies (Vite, Tauri CLI, Signals)
npm install

** Install Latest Tauri CLI (Solves many errors)
npm install -D @tauri-apps/cli@latest

** Final Build Command
npm run build-win

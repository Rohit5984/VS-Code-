Install mysy2 when pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain hit enter and again hit enter to download all required files 
Rustup-init.exe(X64) install select 2 manual options hit enter 
After completing html,css,js 
open VS code terminal
copy these and paste it 

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Add the GNU target
rustup target add x86_64-pc-windows-gnu

# Set it as default
rustup default stable-x86_64-pc-windows-gnu

# Install all node dependencies (Vite, Tauri CLI, Signals)
npm install

# Tauri CLI latest halne (Dherai error yesle solve garchha)
npm install -D @tauri-apps/cli@latest

# Final for making .exe
npm run build-win



# Steps to build a Software

Install MSYS2 and open MSYS2 UCRT64 terminal, then type:
pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain  
Hit enter, it will download all files.

Download Rustup-init.exe (X64), type 2 enter and again enter after completing.

After finishing HTML, CSS, JS setup in VS Code terminal, type these:


```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

rustup target add x86_64-pc-windows-gnu

rustup default stable-x86_64-pc-windows-gnu

Remove-Item -Recurse -Force dist, .vite -ErrorAction SilentlyContinue

if (Test-Path "src-tauri") {
    cd src-tauri
    cargo clean
    Remove-Item -Force Cargo.lock -ErrorAction SilentlyContinue
    cd ..
}

Remove-Item -Recurse -Force node_modules, package-lock.json -ErrorAction SilentlyContinue

npm install
npm install -D @tauri-apps/cli@latest

if (Test-Path "app-icon.png") { Write-Host "[+] New source graphic detected. Compiling multi-platform asset icons..." -ForegroundColor Cyan; npx tauri icon ./app-icon.png }

npm run build-win

# Prompt for AI's like gemini,chatgpt

## Application Identity & Metadata
- **Application Name:** Calculator  
- **Target Build:** Desktop App Interface (Tauri v2, lightweight SPA, 0% external library dependency)

---

## UI/UX Design System (Cyber-Modern / Glassmorphism)
- **Theme & Canvas:** Deep dark-mode base (#050508 / #0a0a0c) with smooth radial gradients (Indigo/Violet).  
- **Accent Palette:** Electric Cyber Cyan (#00f2ff) and Neon Purple (#7000ff) for borders, highlights, and focus states.  
- **Lighting & Glow Effects:** Neon text-shadows for titles, crisp box-shadows with rgba transparency, hover scale-up + glow.  
- **Glassmorphism Spec:**  
  - `background: rgba(255, 255, 255, 0.03)`  
  - `border: 1px solid rgba(255, 255, 255, 0.08)`  
  - `backdrop-filter: blur(12px)`  
- **Typography:** Geometric sans-serif ("Inter", system-ui, sans-serif). Labels and headers in uppercase with letter-spacing.

---

## Interactive Architecture & Logic
- **Layout Topology:** Dual-pane workspace (inputs left/top, outputs right/bottom).  
- **Simplicity Engine:** Structured grid, scannable rows, clean inputs, toggles.  
- **Micro-Interactions:** `transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1)` for fluid, snappy feedback.  
- **State & Validation:** Reactive input tracking, disabled triggers when invalid, safe warnings for missing parameters.

---

## Live Diagnostic Stream
- Real-time styled console inside dashboard.  
- **Message Classes:**  
  - Standard → Cyan/Gray  
  - Success → Emerald Green  
  - Warning → Amber/Orange  
  - Exception → Crimson Red  

---

## Persistent Mandatory Footer
- Centered footer text:  
  `Engineered by Rohit Kr. Mandal`  
- Name styled with Neon Cyan glow.  
- Hyperlink placeholder: [github.com/Rohit5984](https://github.com/Rohit5984)

---

## Core App Functionality
1. Sleek grid layout with operators (+, -, *, /), digits (0–9), decimal, percent, DEL, AC.  
2. Responsive top-aligned display tracking input string + immediate solutions.  
3. Math safety rules: division by zero → intercept instantly, show `"Math Error"` on display, log Crimson Red exception.  
4. Transaction logging: every equation pushes to diagnostic stream, e.g.:  


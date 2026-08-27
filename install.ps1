# install.ps1 - Universal silent installer (PowerShell only, no CMD)
# Right-click this file -> "Run with PowerShell" (or run from an elevated PowerShell).

# --- Self-elevate to Administrator if needed ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$dir   = Split-Path -Parent $PSCommandPath
$log   = Join-Path $dir "install.log"
$files = Get-ChildItem -Path $dir | Where-Object { $_.Extension -in '.exe', '.msi' }
$timeoutMs = 600000   # 10 min per installer; a hang gets killed instead of freezing the run

function Get-ExeArgs($path) {
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $sig   = [System.Text.Encoding]::ASCII.GetString($bytes)
    if ($sig.Contains("Inno Setup")) {
        return @("/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART")
    }
    if ($sig.Contains("Nullsoft")) {
        return @("/S")
    }
    if ($sig.Contains("Windows Installer XML") -or $sig.Contains("Boot")) {
        return @("/quiet", "/norestart")
    }
    return @("/S")   # fallback (WinRAR SFX, etc.)
}

$summary = @()
foreach ($f in $files) {
    if ($f.Extension -eq '.msi') {
        # MSI -> msiexec
        $args = @('/i', "`"$($f.FullName)`"", '/quiet', '/norestart')
        $exe  = 'msiexec'
        $msg  = ("Installing {0}  [MSI]" -f $f.Name)
    } else {
        $args = Get-ExeArgs $f.FullName
        $exe  = $f.FullName
        $msg  = ("Installing {0}  (args: {1})" -f $f.Name, ($args -join " "))
    }
    Write-Host $msg; Add-Content -Path $log -Value $msg

    try {
        $proc = Start-Process -FilePath $exe -ArgumentList $args -PassThru
        if (-not $proc.WaitForExit($timeoutMs)) {
            $proc.Kill()
            $result = "FROZE/TIMED OUT after 10 min - killed (bad silent flag?)"
        } else {
            $result = if ($proc.ExitCode -eq 0) { "OK (exit 0)" } else { "exited with code $($proc.ExitCode)" }
        }
    } catch {
        $result = "FAILED TO START: $($_.Exception.Message)"
    }
    $line = ("  -> {0}" -f $result)
    Write-Host $line; Add-Content -Path $log -Value $line
    $summary += ("{0,-45} {1}" -f $f.Name, $result)
}

Write-Host "`n=========== SUMMARY ==========="
Add-Content -Path $log -Value "`n=========== SUMMARY ==========="
foreach ($s in $summary) { Write-Host $s; Add-Content -Path $log -Value $s }
Write-Host "Log saved to $log"

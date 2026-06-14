param (
    [Parameter(Mandatory = $true)]
    [string]$MountPath
)

Write-Host "Injecting 'Disable ALL Updates' & Recall AI (Nuclear Option)..." -ForegroundColor Cyan

# 1. Load the Offline Software Hive
reg load HKLM\OFFLINE_SOFTWARE "$MountPath\Windows\System32\config\SOFTWARE" | Out-Null

# 2. Block Auto-Update via Policies
& 'reg' 'add' "HKLM\OFFLINE_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" '/v' 'NoAutoUpdate' '/t' 'REG_DWORD' '/d' '1' '/f' | Out-Null
& 'reg' 'add' "HKLM\OFFLINE_SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" '/v' 'AUOptions' '/t' 'REG_DWORD' '/d' '1' '/f' | Out-Null

# 3. Block the Update Medic Service (Hijack the Debugger)
# This prevents the "self-healing" service from ever starting
& 'reg' 'add' "HKLM\OFFLINE_SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\WaaSMedicAgent.exe" '/v' 'Debugger' '/t' 'REG_SZ' '/d' 'systray.exe' '/f' | Out-Null

# 4. Disable Windows Recall AI
& 'reg' 'add' "HKLM\OFFLINE_SOFTWARE\Policies\Microsoft\Windows\WindowsAI" '/v' 'DisableAIDataAnalysis' '/t' 'REG_DWORD' '/d' '1' '/f' | Out-Null

# 5. Load the Offline System Hive (To Disable Services)
reg load HKLM\OFFLINE_SYSTEM "$MountPath\Windows\System32\config\SYSTEM" | Out-Null

# 6. Force-Disable Services at the Driver Level (Start Type 4 = Disabled)
$Services = @("wuauserv", "bits", "dosvc", "UsoSvc", "WaaSMedicSvc")
foreach ($Svc in $Services) {
    $SvcPath = "HKLM:\OFFLINE_SYSTEM\ControlSet001\Services\$Svc"
    if (Test-Path $SvcPath) {
        & 'reg' 'add' "HKLM\OFFLINE_SYSTEM\ControlSet001\Services\$Svc" '/v' 'Start' '/t' 'REG_DWORD' '/d' '4' '/f' | Out-Null
    }
}

# --- UNLOAD HIVES (Critical step or WIM won't unmount) ---
reg unload HKLM\OFFLINE_SOFTWARE | Out-Null
reg unload HKLM\OFFLINE_SYSTEM | Out-Null
Write-Host "Nuclear registry tweaks successfully injected." -ForegroundColor Green

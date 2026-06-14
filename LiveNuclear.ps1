# LiveNuclear.ps1
# Toggles Windows Update and Recall AI on a live running system.
# Must be run as Administrator.

# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script must be run as Administrator!"
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Exit
}

$Services = @("wuauserv", "bits", "dosvc", "UsoSvc", "WaaSMedicSvc")

# Check current status by looking at the NoAutoUpdate policy
$isNuclearON = $false
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (Test-Path $regPath) {
    $val = (Get-ItemProperty -Path $regPath -Name "NoAutoUpdate" -ErrorAction SilentlyContinue).NoAutoUpdate
    if ($val -eq 1) {
        $isNuclearON = $true
    }
}

Clear-Host
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "       Live System Nuclear Option Toggle       " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

if ($isNuclearON) {
    Write-Host "Current Status: " -NoNewline; Write-Host "NUCLEAR OPTION IS ON (Updates Disabled)" -ForegroundColor Red
    Write-Host ""
    $choice = Read-Host "Do you want to turn Windows Updates BACK ON? (Y/N)"
    
    if ($choice -match '^[yY]') {
        Write-Host "`nRe-enabling Windows Updates and Recall AI..." -ForegroundColor Yellow
        
        # 1. Remove Auto-Update Policies
        reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f 2>$null | Out-Null
        
        # 2. Remove the Update Medic Service Hijack
        reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\WaaSMedicAgent.exe" /v "Debugger" /f 2>$null | Out-Null
        
        # 3. Enable Windows Recall AI
        reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /f 2>$null | Out-Null
        
        # 4. Restore Services to default start types (Demand start = 3)
        foreach ($Service in $Services) {
            reg add "HKLM\SYSTEM\CurrentControlSet\Services\$Service" /v "Start" /t REG_DWORD /d 3 /f | Out-Null
        }
        
        Write-Host "Done! Windows Updates are now ENABLED." -ForegroundColor Green
    } else {
        Write-Host "No changes made."
    }

} else {
    Write-Host "Current Status: " -NoNewline; Write-Host "NORMAL (Updates Enabled)" -ForegroundColor Green
    Write-Host ""
    $choice = Read-Host "Do you want to turn ON the Nuclear Option (Disable Updates)? (Y/N)"
    
    if ($choice -match '^[yY]') {
        Write-Host "`nInjecting 'Disable ALL Updates' & Recall AI..." -ForegroundColor Cyan
        
        # 1. Block Auto-Update via Policies
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f | Out-Null
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 1 /f | Out-Null

        # 2. Block the Update Medic Service (Hijack the Debugger)
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\WaaSMedicAgent.exe" /v "Debugger" /t REG_SZ /d "systray.exe" /f | Out-Null

        # 3. Disable Windows Recall AI
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /t REG_DWORD /d 1 /f | Out-Null

        # 4. Force-Disable Services at the Driver Level (Start Type 4 = Disabled)
        foreach ($Service in $Services) {
            reg add "HKLM\SYSTEM\CurrentControlSet\Services\$Service" /v "Start" /t REG_DWORD /d 4 /f | Out-Null
            Stop-Service -Name $Service -Force -ErrorAction SilentlyContinue
        }
        
        Write-Host "Done! Update services have been neutralized." -ForegroundColor Green
    } else {
        Write-Host "No changes made."
    }
}
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

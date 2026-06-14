param(
    [string]$Path = "$PSScriptRoot\scratchdir"
)

# Elevate privileges check
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
if (-not $myWindowsPrincipal.IsInRole($adminRole)) {
    Write-Host "Restarting script as Administrator..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Path `"$Path`"" -Verb RunAs
    exit
}

Write-Host "Starting cleanup for: $Path" -ForegroundColor Cyan

# 1. Force garbage collection to release any lingering file handles before unloading registry
Write-Host "Running garbage collection..."
[GC]::Collect()
[GC]::WaitForPendingFinalizers()

# 2. Unload any registry hives that the script might have left locked
Write-Host "Unloading registry hives..."
$hives = @("zCOMPONENTS", "zDEFAULT", "zNTUSER", "zSOFTWARE", "zSYSTEM", "zSAM", "OFFLINE_SOFTWARE", "OFFLINE_SYSTEM")
foreach ($hive in $hives) {
    reg unload "HKLM\$hive" 2>&1 | Out-Null
}

# 3. Unmount the image and discard any pending changes
Write-Host "Unmounting Windows image..."
Dismount-WindowsImage -Path $Path -Discard -ErrorAction SilentlyContinue | Out-Null
& dism.exe /English /Unmount-Image /MountDir:$Path /Discard 2>&1 | Out-Null

# 4. Clean up the WIM filter driver state to remove any stale mount points
Write-Host "Cleaning up WIM filter driver state..."
& dism.exe /Cleanup-Wim | Out-Null

# 5. Remove the directory completely
if (Test-Path $Path) {
    Write-Host "Removing directory: $Path..."
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path $Path) {
        Write-Host "Failed to remove directory completely. A reboot may be required." -ForegroundColor Yellow
    }
    else {
        Write-Host "Directory removed successfully." -ForegroundColor Green
    }
}
else {
    Write-Host "Directory does not exist. Nothing to remove." -ForegroundColor Green
}

Write-Host "Cleanup finished." -ForegroundColor Cyan
Read-Host "Press Enter to exit"

<#
.SYNOPSIS
    GUI wrapper for tiny11builder.
.DESCRIPTION
    Provides a XAML-based GUI to selectively disable removals and tweaks in tiny11maker.ps1
    without modifying the original source code.
#>

# Ensure running as Admin
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
if (! $myWindowsPrincipal.IsInRole($adminRole)) {
    Write-Host "Restarting GUI as Administrator..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Tiny11 Builder GUI Wrapper" Height="650" Width="500" ResizeMode="NoResize" WindowStartupLocation="CenterScreen">
    <Grid Margin="15">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="0,0,0,15">
            <TextBlock Text="ISO:" VerticalAlignment="Center" Margin="0,0,5,0" FontWeight="SemiBold"/>
            <TextBox Name="txtIsoPath" Width="170" VerticalAlignment="Center" Margin="0,0,5,0" Padding="2"/>
            <Button Name="btnBrowse" Content="Browse" Width="60" Margin="0,0,10,0" Padding="2"/>
            <TextBlock Text="Edition:" VerticalAlignment="Center" Margin="0,0,5,0" FontWeight="SemiBold"/>
            <ComboBox Name="cmbEdition" Width="80" VerticalAlignment="Center" SelectedIndex="0">
                <ComboBoxItem Content="Pro"/>
                <ComboBoxItem Content="Home"/>
                <ComboBoxItem Content="Enterprise"/>
                <ComboBoxItem Content="Education"/>
            </ComboBox>
        </StackPanel>

        <TextBlock Grid.Row="1" Text="Select modifications (Uncheck to keep components):" FontWeight="Bold" Margin="0,0,0,10"/>

        <StackPanel Grid.Row="2">
            <CheckBox Name="chkApps" Content="Remove Inbox Bloatware (Clipchamp, Xbox, etc.)" IsChecked="True" Margin="0,5"/>
            <CheckBox Name="chkEdge" Content="Remove Microsoft Edge" IsChecked="True" Margin="0,5"/>
            <CheckBox Name="chkOneDrive" Content="Remove OneDrive" IsChecked="True" Margin="0,5"/>
            <CheckBox Name="chkReqs" Content="Bypass Windows 11 Hardware Requirements" IsChecked="True" Margin="0,5"/>
            <CheckBox Name="chkTelemetry" Content="Disable Telemetry &amp; Sponsored Apps" IsChecked="True" Margin="0,5"/>
            <CheckBox Name="chkCopilot" Content="Disable Copilot &amp; Web Search" IsChecked="True" Margin="0,5"/>
            <CheckBox Name="chkNuclear" Content="Nuclear Option: Disable ALL Updates &amp; Recall AI" IsChecked="False" Margin="0,5"/>
            <CheckBox Name="chkLocalAccount" Content="Bypass MS Account (Force Local Account on OOBE)" IsChecked="True" Margin="0,5"/>
            <CheckBox Name="chkBitLocker" Content="Disable Automatic BitLocker Encryption" IsChecked="True" Margin="0,5"/>
            <CheckBox Name="chkTasks" Content="Remove Scheduled Telemetry Tasks (CEIP, Appraiser)" IsChecked="True" Margin="0,5"/>
            <CheckBox Name="chkSoftware" Content="Inject Custom Post-Setup Software (.exe, .msi, .ps1)" IsChecked="False" Margin="0,5"/>
        </StackPanel>

        <StackPanel Grid.Row="3" Orientation="Horizontal" Margin="0,0,0,15">
            <CheckBox Name="chkBuiltInAdmin" Content="Built-in Admin" VerticalAlignment="Center" Margin="0,0,10,0" FontWeight="SemiBold" ToolTip="Use built-in Administrator account"/>
            <TextBlock Text="User:" VerticalAlignment="Center" Margin="0,0,5,0" FontWeight="SemiBold"/>
            <TextBox Name="txtUsername" Width="90" Text="User" VerticalAlignment="Center" Margin="0,0,15,0" Padding="2"/>
            <TextBlock Text="Pass:" VerticalAlignment="Center" Margin="0,0,5,0" FontWeight="SemiBold"/>
            <TextBox Name="txtPassword" Width="90" VerticalAlignment="Center" Padding="2" ToolTip="Leave blank for no password"/>
        </StackPanel>

        <Grid Grid.Row="4">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            <Button Name="btnOpenUpdates" Grid.Column="0" Content="Updates (.msu)" Height="35" Margin="0,0,5,0" FontWeight="SemiBold" ToolTip="Place your Windows Update files here before building."/>
            <Button Name="btnOpenSoftware" Grid.Column="1" Content="Software (.exe)" Height="35" Margin="0,0,5,0" FontWeight="SemiBold" ToolTip="Place post-setup installers here."/>
            <Button Name="btnRun" Grid.Column="2" Content="Build Tiny11 ISO" Height="35" Margin="5,0,0,0" FontWeight="Bold"/>
        </Grid>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$txtIsoPath = $window.FindName("txtIsoPath")
$btnBrowse = $window.FindName("btnBrowse")
$chkApps = $window.FindName("chkApps")
$chkEdge = $window.FindName("chkEdge")
$chkOneDrive = $window.FindName("chkOneDrive")
$chkReqs = $window.FindName("chkReqs")
$chkTelemetry = $window.FindName("chkTelemetry")
$chkCopilot = $window.FindName("chkCopilot")
$chkNuclear = $window.FindName("chkNuclear")
$chkLocalAccount = $window.FindName("chkLocalAccount")
$chkBitLocker = $window.FindName("chkBitLocker")
$chkTasks = $window.FindName("chkTasks")
$chkSoftware = $window.FindName("chkSoftware")
$chkBuiltInAdmin = $window.FindName("chkBuiltInAdmin")
$txtUsername = $window.FindName("txtUsername")
$txtPassword = $window.FindName("txtPassword")
$cmbEdition = $window.FindName("cmbEdition")
$btnOpenUpdates = $window.FindName("btnOpenUpdates")
$btnOpenSoftware = $window.FindName("btnOpenSoftware")
$btnRun = $window.FindName("btnRun")

$chkBuiltInAdmin.Add_Checked({
        $txtUsername.IsEnabled = $false
    })
$chkBuiltInAdmin.Add_Unchecked({
        $txtUsername.IsEnabled = $true
    })

$btnBrowse.Add_Click({
        Add-Type -AssemblyName System.Windows.Forms
        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Filter = "ISO Files (*.iso)|*.iso|All Files (*.*)|*.*"
        $openFileDialog.Title = "Select Windows 11 ISO"
        if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $txtIsoPath.Text = $openFileDialog.FileName
        }
    })

$btnOpenUpdates.Add_Click({
        $updatesFolder = Join-Path $PSScriptRoot "updates"
        if (-not (Test-Path $updatesFolder)) {
            New-Item -ItemType Directory -Path $updatesFolder | Out-Null
        }
        Invoke-Item $updatesFolder
    })

$btnOpenSoftware.Add_Click({
        $softwareFolder = Join-Path $PSScriptRoot "software"
        if (-not (Test-Path $softwareFolder)) {
            New-Item -ItemType Directory -Path $softwareFolder | Out-Null
        }
        Invoke-Item $softwareFolder
    })

$btnRun.Add_Click({
        $isoInput = $txtIsoPath.Text.Trim()
        $driveLetter = ""

        if ([string]::IsNullOrWhiteSpace($isoInput)) {
            [System.Windows.MessageBox]::Show("Please select an ISO file or enter a drive letter.")
            return
        }

        if ($isoInput -match '^[c-zC-Z]:?$') {
            $driveLetter = $isoInput[0]
        }
        elseif (Test-Path $isoInput) {
            $mountResult = Mount-DiskImage -ImagePath $isoInput -PassThru
            $driveLetter = ($mountResult | Get-Volume).DriveLetter
            if (-not $driveLetter) {
                [System.Windows.MessageBox]::Show("Failed to mount ISO or retrieve drive letter.")
                return
            }
        }
        else {
            [System.Windows.MessageBox]::Show("Invalid ISO path or drive letter.")
            return
        }

        $scriptPath = Join-Path $PSScriptRoot "tiny11maker.ps1"
        if (-not (Test-Path $scriptPath)) {
            [System.Windows.MessageBox]::Show("Could not find tiny11maker.ps1 in the current directory.")
            return
        }

        $content = Get-Content $scriptPath -Raw

        # 1. Apps
        if (-not $chkApps.IsChecked) {
            $content = $content.Replace('foreach ($package in $packagesToRemove)', "`$packagesToRemove = @()`nforeach (`$package in `$packagesToRemove)")
        }

        # 2. Edge
        if (-not $chkEdge.IsChecked) {
            $content = $content.Replace('Write-Output "Removing Edge:"', 'if ($false) { Write-Output "Removing Edge:"')
            $content = $content.Replace('Write-Output "Removing OneDrive:"', '} Write-Output "Removing OneDrive:"')

            $content = $content.Replace('Write-Output "Removing Edge related registries"', 'if ($false) { Write-Output "Removing Edge related registries"')
            $content = $content.Replace('Write-Output "Disabling OneDrive folder backup"', '} Write-Output "Disabling OneDrive folder backup"')
        }

        # 3. OneDrive
        if (-not $chkOneDrive.IsChecked) {
            $content = $content.Replace('Write-Output "Removing OneDrive:"', 'if ($false) { Write-Output "Removing OneDrive:"')
            $content = $content.Replace('Write-Output "Removing MS Paint (System32):"', '} Write-Output "Removing MS Paint (System32):"')

            $content = $content.Replace('Write-Output "Disabling OneDrive folder backup"', 'if ($false) { Write-Output "Disabling OneDrive folder backup"')
            $content = $content.Replace('Write-Output "Disabling Telemetry:"', '} Write-Output "Disabling Telemetry:"')
        }

        # 4. HW Requirements
        if (-not $chkReqs.IsChecked) {
            $content = $content.Replace('Write-Output "Bypassing system requirements(on the system image):"', 'if ($false) { Write-Output "Bypassing system requirements(on the system image):"')
            $content = $content.Replace('Write-Output "Disabling Sponsored Apps:"', '} Write-Output "Disabling Sponsored Apps:"')
            $content = $content.Replace('Write-Output "Bypassing system requirements(on the setup image):"', 'if ($false) { Write-Output "Bypassing system requirements(on the setup image):"')
            $content = $content.Replace('Write-Output "Tweaking complete!"', '} Write-Output "Tweaking complete!"')
        }

        # 5. Telemetry
        if (-not $chkTelemetry.IsChecked) {
            $content = $content.Replace('Write-Output "Disabling Telemetry:"', 'if ($false) { Write-Output "Disabling Telemetry:"')
            $content = $content.Replace('Write-Output "Prevents installation of DevHome and Outlook:"', '} Write-Output "Prevents installation of DevHome and Outlook:"')
        }

        # 6. Copilot
        if (-not $chkCopilot.IsChecked) {
            $content = $content.Replace('Write-Output "Disabling Copilot"', 'if ($false) { Write-Output "Disabling Copilot"')
            $content = $content.Replace('Write-Output "Prevents installation of Teams:"', '} Write-Output "Prevents installation of Teams:"')
        }

        # 7. Nuclear Option
        if ($chkNuclear.IsChecked) {
            $nuclearSnippet = @"
`$nuclearScript = Join-Path `$PSScriptRoot `"DisableNuclear.ps1`"
if (Test-Path `$nuclearScript) {
    & `$nuclearScript -MountPath `"`$ScratchDisk\scratchdir`"
}
"@
            $content = $content.Replace('Write-Output "Cleaning up image..."', "`n$nuclearSnippet`nWrite-Output `"Cleaning up image...`"")
        }

        # 8. Local Account
        if ($chkLocalAccount.IsChecked) {
            $user = $txtUsername.Text.Trim().Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;').Replace("'", '&apos;')
            if ([string]::IsNullOrWhiteSpace($user)) { $user = "User" }
            $pass = $txtPassword.Text.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;').Replace("'", '&apos;')
            $useBuiltIn = if ($chkBuiltInAdmin.IsChecked) { '$true' } else { '$false' }

            $xmlTweak = @"
`$xmlPaths = @(`"`$ScratchDisk\scratchdir\Windows\System32\Sysprep\autounattend.xml`", `"`$ScratchDisk\tiny11\autounattend.xml`")
foreach (`$xmlPath in `$xmlPaths) {
    if (Test-Path `$xmlPath) {
        `$xmlContent = Get-Content `$xmlPath -Raw

        if ($useBuiltIn) {
            `$targetUser = 'Administrator'
            `$userAccountBlock = '<UserAccounts>
                <LocalAccounts>
                    <LocalAccount wcm:action="modify">
                        <Name>Administrator</Name>
                        <Group>Administrators</Group>
                        <Active>true</Active>
                    </LocalAccount>
                </LocalAccounts>'
            if ('$pass' -ne '') {
                `$userAccountBlock += '<AdministratorPassword><Value>$pass</Value><PlainText>true</PlainText></AdministratorPassword>'
            }
            `$userAccountBlock += '</UserAccounts>'
        } else {
            `$targetUser = '$user'
            `$userAccountBlock = '<UserAccounts>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Name>$user</Name>
                        <DisplayName>$user</DisplayName>
                        <Group>Administrators</Group>'
            if ('$pass' -ne '') {
                `$userAccountBlock += '<Password><Value>$pass</Value><PlainText>true</PlainText></Password>'
            }
            `$userAccountBlock += '</LocalAccount>
                </LocalAccounts>
            </UserAccounts>'
        }

        `$autoLogonBlock = '<AutoLogon>'
        if ('$pass' -ne '') {
            `$autoLogonBlock += '<Password><Value>$pass</Value><PlainText>true</PlainText></Password>'
        }
        `$autoLogonBlock += '<Enabled>true</Enabled>
                <LogonCount>9999999</LogonCount>
                <Username>' + `$targetUser + '</Username>
            </AutoLogon>'

        # Remove existing UserAccounts/AutoLogon if any
        `$xmlContent = `$xmlContent -replace '(?si)<UserAccounts>.*?</UserAccounts>', ''
        `$xmlContent = `$xmlContent -replace '(?si)<AutoLogon>.*?</AutoLogon>', ''

        # Insert after </OOBE>
        `$replacement = "</OOBE>`r`n            `$userAccountBlock`r`n            `$autoLogonBlock"
        `$xmlContent = `$xmlContent.Replace('</OOBE>', `$replacement)

        Set-Content -Path `$xmlPath -Value `$xmlContent -Encoding UTF8
    }
}
"@
            $content = $content.Replace('Write-Output "Creating ISO image..."', "`n$xmlTweak`nWrite-Output `"Creating ISO image...`"")
        }
        else {
            $content = $content.Replace('Write-Output "Enabling Local Accounts on OOBE:"', 'if ($false) { Write-Output "Enabling Local Accounts on OOBE:"')
            $content = $content.Replace('Write-Output "Disabling Reserved Storage:"', '} Write-Output "Disabling Reserved Storage:"')

            $content = $content.Replace('Write-Output "Copying unattended file for bypassing MS account on OOBE..."', 'if ($false) { Write-Output "Copying unattended file for bypassing MS account on OOBE..."')
            $content = $content.Replace('Write-Output "Creating ISO image..."', '} Write-Output "Creating ISO image..."')
        }

        # 9. BitLocker
        if (-not $chkBitLocker.IsChecked) {
            $content = $content.Replace('Write-Output "Disabling BitLocker Device Encryption"', 'if ($false) { Write-Output "Disabling BitLocker Device Encryption"')
            $content = $content.Replace('Write-Output "Disabling Chat icon:"', '} Write-Output "Disabling Chat icon:"')
        }

        # 10. Tasks
        if (-not $chkTasks.IsChecked) {
            $content = $content.Replace('Write-Host "Deleting scheduled task definition files..."', 'if ($false) { Write-Host "Deleting scheduled task definition files..."')
            $content = $content.Replace('Write-Host "Task files have been deleted."', '} Write-Host "Task files have been deleted."')
        }

        # 11. Auto-Select Edition Index
        $edition = $cmbEdition.Text
        if ([string]::IsNullOrWhiteSpace($edition) -and $null -ne $cmbEdition.SelectedItem) {
            $edition = $cmbEdition.SelectedItem.Content.ToString()
        }
        $autoIndexLogic = "`$images = @(); if (Test-Path `"`$ScratchDisk\tiny11\sources\install.wim`") { `$images = Get-WindowsImage -ImagePath `"`$ScratchDisk\tiny11\sources\install.wim`" } elseif (Test-Path `"`$DriveLetter\sources\install.esd`") { `$images = Get-WindowsImage -ImagePath `"`$DriveLetter\sources\install.esd`" } elseif (Test-Path `"`$DriveLetter\sources\install.wim`") { `$images = Get-WindowsImage -ImagePath `"`$DriveLetter\sources\install.wim`" }; `$index = `$images | Where-Object { `$_.ImageName -match '\b$edition\b' } | Select-Object -ExpandProperty ImageIndex -First 1; if (-not `$index) { `$index = 1 }; Write-Output `"Auto-selected Image Index: `$index`""
        $content = $content.Replace('$index = Read-Host "Please enter the image index"', $autoIndexLogic)

        # 12. Skip Edition Prompt
        $editionMap = @{
            "Pro"        = "Professional"
            "Home"       = "Core"
            "Enterprise" = "Enterprise"
            "Education"  = "Education"
        }
        $mappedEdition = $editionMap[$edition]
        if (-not $mappedEdition) { $mappedEdition = "Professional" }

        $eiCfgFix = @"
`$eiCfgPath = `"`$ScratchDisk\tiny11\sources\ei.cfg`"
`"[EditionID]``r``n$mappedEdition``r``n[Channel]``r``nRetail``r``n[VL]``r``n0`" | Out-File -FilePath `$eiCfgPath -Encoding ASCII
"@
        $content = $content.Replace('Write-Output "Creating ISO image..."', "`n$eiCfgFix`nWrite-Output `"Creating ISO image...`"")

        # 13. Custom Post-Setup Software Installer
        if ($chkSoftware.IsChecked) {
            $softwareLogic = @'
$softwareFolder = Join-Path $PSScriptRoot "software"
if (Test-Path $softwareFolder) {
    Write-Output "Injecting custom post-setup software/scripts..."
    $scriptsDir = "$ScratchDisk\scratchdir\Windows\Setup\Scripts"
    New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
    Copy-Item -Path "$softwareFolder\*" -Destination $scriptsDir -Recurse -Force

    $guiScript = "$scriptsDir\InstallGUI.ps1"
    $guiContent = @"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

`$form = New-Object System.Windows.Forms.Form
`$form.Text = 'Software Installer'
`$form.Size = New-Object System.Drawing.Size(300,160)
`$form.StartPosition = 'CenterScreen'
`$form.TopMost = `$true

`$label = New-Object System.Windows.Forms.Label
`$label.Text = 'Select drive to install custom software to:'
`$label.Location = New-Object System.Drawing.Point(10,20)
`$label.AutoSize = `$true
`$form.Controls.Add(`$label)

`$comboBox = New-Object System.Windows.Forms.ComboBox
`$comboBox.Location = New-Object System.Drawing.Point(10,50)
`$comboBox.Width = 260
`$comboBox.DropDownStyle = 'DropDownList'
foreach (`$drive in (Get-PSDrive -PSProvider FileSystem)) {
    if (`$drive.Free -gt 0) {
        `$comboBox.Items.Add(`$drive.Name + ':\') | Out-Null
    }
}
`$comboBox.SelectedIndex = 0
`$form.Controls.Add(`$comboBox)

`$btn = New-Object System.Windows.Forms.Button
`$btn.Text = 'Install'
`$btn.Location = New-Object System.Drawing.Point(10,80)
`$btn.DialogResult = 'OK'
`$form.Controls.Add(`$btn)

`$form.AcceptButton = `$btn
`$result = `$form.ShowDialog()

if (`$result -eq 'OK') {
    `$targetDrive = `$comboBox.SelectedItem.ToString()
    `$scriptPath = Split-Path -Parent `$MyInvocation.MyCommand.Definition

    foreach (`$msi in Get-ChildItem -Path `$scriptPath -Filter '*.msi') {
        `$msiArgs = '/i "' + `$msi.FullName + '" /qn /norestart TARGETDIR="' + `$targetDrive + '" INSTALLDIR="' + `$targetDrive + '"'
        Start-Process 'msiexec.exe' -ArgumentList `$msiArgs -Wait
    }

    foreach (`$exe in Get-ChildItem -Path `$scriptPath -Filter '*.exe') {
        `$exeArgs = '/S /quiet /norestart /DIR="' + `$targetDrive + '" /D=' + `$targetDrive
        Start-Process `$exe.FullName -ArgumentList `$exeArgs -Wait
    }

    foreach (`$ps1 in Get-ChildItem -Path `$scriptPath -Filter '*.ps1') {
        if (`$ps1.Name -ne 'InstallGUI.ps1') {
            `$psArgs = '-NoProfile -ExecutionPolicy Bypass -File "' + `$ps1.FullName + '"'
            Start-Process 'powershell.exe' -ArgumentList `$psArgs -Wait
        }
    }
}
"@
    Set-Content -Path $guiScript -Value $guiContent -Encoding Ascii

    $setupComplete = "$scriptsDir\SetupComplete.cmd"
    if (-not (Test-Path $setupComplete)) {
        $cmdContent = "@echo off`r`n"
        $cmdContent += "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"%~dp0InstallGUI.ps1`"`r`n"
        $cmdContent += "del /q /f `"%~dp0*.*`"`r`n"
        Set-Content -Path $setupComplete -Value $cmdContent -Encoding Ascii
    }
}
'@
            $content = $content.Replace('Write-Output "Cleaning up image..."', "`n$softwareLogic`nWrite-Output `"Cleaning up image...`"")
        }

        $tempScript = Join-Path $PSScriptRoot "tiny11_custom_build.ps1"
        Set-Content -Path $tempScript -Value $content -Encoding UTF8

        $btnRun.IsEnabled = $false
        Start-Process powershell -ArgumentList "-NoExit -NoProfile -ExecutionPolicy Bypass -File `"$tempScript`" -ISO $driveLetter"
        $window.Close()
    })

$window.ShowDialog() | Out-Null

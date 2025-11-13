# DW Spectrum Multi-Monitor Installer
# GUI application to configure and install DW Spectrum launcher

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'DW Spectrum Multi-Monitor Setup'
$form.Size = New-Object System.Drawing.Size(600, 700)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# Title Label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Size = New-Object System.Drawing.Size(560, 30)
$titleLabel.Text = 'DW Spectrum Multi-Monitor Configuration'
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($titleLabel)

# Subtitle Label
$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Location = New-Object System.Drawing.Point(20, 55)
$subtitleLabel.Size = New-Object System.Drawing.Size(560, 20)
$subtitleLabel.Text = 'Configure your DW Spectrum server and monitor settings'
$subtitleLabel.ForeColor = [System.Drawing.Color]::Gray
$form.Controls.Add($subtitleLabel)

# Separator
$separator1 = New-Object System.Windows.Forms.Label
$separator1.Location = New-Object System.Drawing.Point(20, 85)
$separator1.Size = New-Object System.Drawing.Size(560, 2)
$separator1.BorderStyle = 'Fixed3D'
$form.Controls.Add($separator1)

$yPos = 100

# Server IP Label and TextBox
$serverIPLabel = New-Object System.Windows.Forms.Label
$serverIPLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$serverIPLabel.Size = New-Object System.Drawing.Size(150, 20)
$serverIPLabel.Text = 'Server IP Address:'
$form.Controls.Add($serverIPLabel)

$serverIPBox = New-Object System.Windows.Forms.TextBox
$serverIPBox.Location = New-Object System.Drawing.Point(180, $yPos)
$serverIPBox.Size = New-Object System.Drawing.Size(200, 20)
$serverIPBox.Text = '47.181.107.95'
$form.Controls.Add($serverIPBox)

$yPos += 35

# Server Port Label and TextBox
$serverPortLabel = New-Object System.Windows.Forms.Label
$serverPortLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$serverPortLabel.Size = New-Object System.Drawing.Size(150, 20)
$serverPortLabel.Text = 'Server Port:'
$form.Controls.Add($serverPortLabel)

$serverPortBox = New-Object System.Windows.Forms.TextBox
$serverPortBox.Location = New-Object System.Drawing.Point(180, $yPos)
$serverPortBox.Size = New-Object System.Drawing.Size(200, 20)
$serverPortBox.Text = '7001'
$form.Controls.Add($serverPortBox)

$yPos += 35

# Username Label and TextBox
$usernameLabel = New-Object System.Windows.Forms.Label
$usernameLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$usernameLabel.Size = New-Object System.Drawing.Size(150, 20)
$usernameLabel.Text = 'Username:'
$form.Controls.Add($usernameLabel)

$usernameBox = New-Object System.Windows.Forms.TextBox
$usernameBox.Location = New-Object System.Drawing.Point(180, $yPos)
$usernameBox.Size = New-Object System.Drawing.Size(200, 20)
$usernameBox.Text = 'LocalOffice'
$form.Controls.Add($usernameBox)

$yPos += 35

# Password Label and TextBox
$passwordLabel = New-Object System.Windows.Forms.Label
$passwordLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$passwordLabel.Size = New-Object System.Drawing.Size(150, 20)
$passwordLabel.Text = 'Password:'
$form.Controls.Add($passwordLabel)

$passwordBox = New-Object System.Windows.Forms.TextBox
$passwordBox.Location = New-Object System.Drawing.Point(180, $yPos)
$passwordBox.Size = New-Object System.Drawing.Size(200, 20)
$passwordBox.PasswordChar = '*'
$form.Controls.Add($passwordBox)

# Show Password Checkbox
$showPasswordCheck = New-Object System.Windows.Forms.CheckBox
$showPasswordCheck.Location = New-Object System.Drawing.Point(390, $yPos)
$showPasswordCheck.Size = New-Object System.Drawing.Size(150, 20)
$showPasswordCheck.Text = 'Show Password'
$showPasswordCheck.Add_CheckedChanged({
    if ($showPasswordCheck.Checked) {
        $passwordBox.PasswordChar = ''
    } else {
        $passwordBox.PasswordChar = '*'
    }
})
$form.Controls.Add($showPasswordCheck)

$yPos += 35

# Separator
$separator2 = New-Object System.Windows.Forms.Label
$separator2.Location = New-Object System.Drawing.Point(20, $yPos)
$separator2.Size = New-Object System.Drawing.Size(560, 2)
$separator2.BorderStyle = 'Fixed3D'
$form.Controls.Add($separator2)

$yPos += 15

# Number of Monitors Label and ComboBox
$monitorsLabel = New-Object System.Windows.Forms.Label
$monitorsLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$monitorsLabel.Size = New-Object System.Drawing.Size(150, 20)
$monitorsLabel.Text = 'Number of Monitors:'
$form.Controls.Add($monitorsLabel)

$monitorsCombo = New-Object System.Windows.Forms.ComboBox
$monitorsCombo.Location = New-Object System.Drawing.Point(180, $yPos)
$monitorsCombo.Size = New-Object System.Drawing.Size(200, 20)
$monitorsCombo.DropDownStyle = 'DropDownList'
$monitorsCombo.Items.AddRange(@('1', '2', '3', '4', '5', '6'))
$monitorsCombo.SelectedIndex = 1  # Default to 2 monitors
$form.Controls.Add($monitorsCombo)

$yPos += 35

# Layout Names Section
$layoutsLabel = New-Object System.Windows.Forms.Label
$layoutsLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$layoutsLabel.Size = New-Object System.Drawing.Size(560, 20)
$layoutsLabel.Text = 'Layout Names (must match saved layouts in DW Spectrum):'
$layoutsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($layoutsLabel)

$yPos += 30

# Create layout textboxes dynamically based on monitor count
$layoutBoxes = @()
for ($i = 0; $i -lt 6; $i++) {
    $layoutLabel = New-Object System.Windows.Forms.Label
    $layoutLabel.Location = New-Object System.Drawing.Point(20, $yPos + ($i * 30))
    $layoutLabel.Size = New-Object System.Drawing.Size(150, 20)
    $layoutLabel.Text = "Monitor $($i + 1) Layout:"
    $layoutLabel.Visible = ($i -lt 2)  # Only show first 2 by default
    $form.Controls.Add($layoutLabel)

    $layoutBox = New-Object System.Windows.Forms.TextBox
    $layoutBox.Location = New-Object System.Drawing.Point(180, $yPos + ($i * 30))
    $layoutBox.Size = New-Object System.Drawing.Size(200, 20)
    $layoutBox.Visible = ($i -lt 2)  # Only show first 2 by default
    if ($i -eq 0) { $layoutBox.Text = 'Left Screen' }
    if ($i -eq 1) { $layoutBox.Text = 'Right Screen' }
    $form.Controls.Add($layoutBox)

    $layoutBoxes += @{Label = $layoutLabel; TextBox = $layoutBox}
}

# Update visible layout boxes when monitor count changes
$monitorsCombo.Add_SelectedIndexChanged({
    $count = [int]$monitorsCombo.SelectedItem
    for ($i = 0; $i -lt 6; $i++) {
        $layoutBoxes[$i].Label.Visible = ($i -lt $count)
        $layoutBoxes[$i].TextBox.Visible = ($i -lt $count)
    }
})

$yPos += 200

# Installation Path Label
$pathLabel = New-Object System.Windows.Forms.Label
$pathLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$pathLabel.Size = New-Object System.Drawing.Size(150, 20)
$pathLabel.Text = 'DW Spectrum Path:'
$form.Controls.Add($pathLabel)

$pathBox = New-Object System.Windows.Forms.TextBox
$pathBox.Location = New-Object System.Drawing.Point(180, $yPos)
$pathBox.Size = New-Object System.Drawing.Size(350, 20)
$pathBox.ReadOnly = $true
$pathBox.BackColor = [System.Drawing.Color]::WhiteSmoke
$form.Controls.Add($pathBox)

# Auto-detect DW Spectrum installation
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(540, $yPos)
$browseButton.Size = New-Object System.Drawing.Size(40, 23)
$browseButton.Text = '...'
$browseButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = 'DW Spectrum Launcher|DW Spectrum Launcher.exe'
    $openFileDialog.Title = 'Select DW Spectrum Launcher.exe'
    if ($openFileDialog.ShowDialog() -eq 'OK') {
        $pathBox.Text = $openFileDialog.FileName
    }
})
$form.Controls.Add($browseButton)

# Auto-detect installation path
function Find-DWSpectrumPath {
    $possiblePaths = @(
        "C:\Program Files\Digital Watchdog\DW Spectrum\Client",
        "C:\Program Files (x86)\Digital Watchdog\DW Spectrum\Client"
    )

    foreach ($basePath in $possiblePaths) {
        if (Test-Path $basePath) {
            $versions = Get-ChildItem $basePath -Directory | Sort-Object Name -Descending
            foreach ($version in $versions) {
                $launcherPath = Join-Path $version.FullName "DW Spectrum Launcher.exe"
                if (Test-Path $launcherPath) {
                    return $launcherPath
                }
            }
        }
    }
    return $null
}

$detectedPath = Find-DWSpectrumPath
if ($detectedPath) {
    $pathBox.Text = $detectedPath
} else {
    $pathBox.Text = "Not found - click '...' to browse"
}

$yPos += 35

# Auto-start checkbox
$autoStartCheck = New-Object System.Windows.Forms.CheckBox
$autoStartCheck.Location = New-Object System.Drawing.Point(20, $yPos)
$autoStartCheck.Size = New-Object System.Drawing.Size(300, 20)
$autoStartCheck.Text = 'Enable auto-start on Windows login'
$autoStartCheck.Checked = $true
$form.Controls.Add($autoStartCheck)

$yPos += 35

# Status Label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$statusLabel.Size = New-Object System.Drawing.Size(560, 40)
$statusLabel.Text = ''
$statusLabel.ForeColor = [System.Drawing.Color]::Blue
$form.Controls.Add($statusLabel)

$yPos += 50

# Install Button
$installButton = New-Object System.Windows.Forms.Button
$installButton.Location = New-Object System.Drawing.Point(380, $yPos)
$installButton.Size = New-Object System.Drawing.Size(100, 35)
$installButton.Text = 'Install'
$installButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$installButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$installButton.ForeColor = [System.Drawing.Color]::White
$installButton.FlatStyle = 'Flat'
$installButton.Add_Click({
    # Validate inputs
    if ([string]::IsNullOrWhiteSpace($serverIPBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show('Please enter a server IP address.', 'Validation Error', 'OK', 'Error')
        return
    }

    if ([string]::IsNullOrWhiteSpace($serverPortBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show('Please enter a server port.', 'Validation Error', 'OK', 'Error')
        return
    }

    if ([string]::IsNullOrWhiteSpace($usernameBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show('Please enter a username.', 'Validation Error', 'OK', 'Error')
        return
    }

    if ([string]::IsNullOrWhiteSpace($passwordBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show('Please enter a password.', 'Validation Error', 'OK', 'Error')
        return
    }

    if ([string]::IsNullOrWhiteSpace($pathBox.Text) -or $pathBox.Text -eq "Not found - click '...' to browse") {
        [System.Windows.Forms.MessageBox]::Show('Please select the DW Spectrum Launcher.exe path.', 'Validation Error', 'OK', 'Error')
        return
    }

    if (-not (Test-Path $pathBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show('DW Spectrum Launcher.exe not found at the specified path.', 'Validation Error', 'OK', 'Error')
        return
    }

    # Validate layout names
    $monitorCount = [int]$monitorsCombo.SelectedItem
    for ($i = 0; $i -lt $monitorCount; $i++) {
        if ([string]::IsNullOrWhiteSpace($layoutBoxes[$i].TextBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter a layout name for Monitor $($i + 1).", 'Validation Error', 'OK', 'Error')
            return
        }
    }

    $statusLabel.Text = 'Installing...'
    $statusLabel.ForeColor = [System.Drawing.Color]::Blue
    $installButton.Enabled = $false
    $cancelButton.Enabled = $false

    try {
        # Generate the launcher script
        $scriptContent = @"
# DW Spectrum Multi-Monitor Launcher
# Auto-generated by DW Spectrum Installer

# Configuration
`$dwSpectrumPath = "$($pathBox.Text)"
`$serverIP = "$($serverIPBox.Text)"
`$serverPort = "$($serverPortBox.Text)"
`$username = "$($usernameBox.Text)"
`$password = "$($passwordBox.Text)"

# Layout names
"@

        for ($i = 0; $i -lt $monitorCount; $i++) {
            $scriptContent += "`n`$monitor$($i + 1)Layout = `"$($layoutBoxes[$i].TextBox.Text)`""
        }

        $scriptContent += @"


# Verify DW Spectrum is installed
if (-not (Test-Path `$dwSpectrumPath)) {
    Write-Host "ERROR: DW Spectrum not found at: `$dwSpectrumPath" -ForegroundColor Red
    Write-Host "Please verify the installation path and update the script." -ForegroundColor Yellow
    pause
    exit
}

Write-Host "Launching DW Spectrum on $monitorCount monitor(s)..." -ForegroundColor Green
Write-Host "Server: `$serverIP``:`$serverPort" -ForegroundColor Cyan
Write-Host ""

# Build authentication string (URL encode special characters in password)
`$encodedPassword = `$password -replace '@', '%40' -replace '&', '%26'
`$authString = "http://`${username}:`${encodedPassword}@`${serverIP}:`${serverPort}"

"@

        # Generate launch commands for each monitor
        for ($i = 0; $i -lt $monitorCount; $i++) {
            $monNum = $i + 1
            $scriptContent += @"

# Launch Monitor $monNum (Screen $i)
Write-Host "Starting Monitor $monNum..." -ForegroundColor Yellow
`$arguments$monNum = @(
    "--no-single-application",
    "--auth=`$authString",
    "--layout-name=```"```$monitor${monNum}Layout```"",
    "--screen=$i",
    "--no-client-update"
)
Start-Process -FilePath `$dwSpectrumPath -ArgumentList `$arguments$monNum

"@
            if ($i -lt $monitorCount - 1) {
                $scriptContent += "# Wait before launching next instance`nStart-Sleep -Seconds 2`n"
            }
        }

        $scriptContent += @"

Write-Host ""
Write-Host "All instances launched successfully!" -ForegroundColor Green
"@

        # Determine installation directory
        $installDir = Join-Path $env:USERPROFILE "DW Spectrum Launcher"
        if (-not (Test-Path $installDir)) {
            New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        }

        # Save the launcher script
        $launcherScriptPath = Join-Path $installDir "Launch-DWSpectrum.ps1"
        $scriptContent | Out-File -FilePath $launcherScriptPath -Encoding UTF8 -Force

        # Create batch file
        $batchContent = @"
@echo off
REM DW Spectrum Multi-Monitor Launcher
REM Double-click this file to launch DW Spectrum on all monitors

echo Starting DW Spectrum Multi-Monitor Setup...
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0Launch-DWSpectrum.ps1"

if errorlevel 1 (
    echo.
    echo An error occurred. Press any key to exit...
    pause >nul
)
"@
        $batchPath = Join-Path $installDir "Launch-DWSpectrum.bat"
        $batchContent | Out-File -FilePath $batchPath -Encoding ASCII -Force

        # Create desktop shortcut
        $WScriptShell = New-Object -ComObject WScript.Shell
        $desktopPath = [Environment]::GetFolderPath('Desktop')
        $shortcutPath = Join-Path $desktopPath "Launch DW Spectrum.lnk"
        $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $batchPath
        $shortcut.WorkingDirectory = $installDir
        $shortcut.Description = "Launch DW Spectrum on multiple monitors"
        $shortcut.Save()

        # Enable auto-start if checked
        if ($autoStartCheck.Checked) {
            $startupFolder = [Environment]::GetFolderPath('Startup')
            $startupShortcutPath = Join-Path $startupFolder "Launch DW Spectrum.lnk"
            $startupShortcut = $WScriptShell.CreateShortcut($startupShortcutPath)
            $startupShortcut.TargetPath = $batchPath
            $startupShortcut.WorkingDirectory = $installDir
            $startupShortcut.Description = "Launch DW Spectrum on multiple monitors"
            $startupShortcut.Save()
        }

        $statusLabel.Text = "Installation completed successfully!`nShortcut created on Desktop."
        $statusLabel.ForeColor = [System.Drawing.Color]::Green

        $result = [System.Windows.Forms.MessageBox]::Show(
            "DW Spectrum launcher has been installed successfully!`n`n" +
            "Files installed to: $installDir`n" +
            "Desktop shortcut created: Launch DW Spectrum.lnk`n" +
            $(if ($autoStartCheck.Checked) { "Auto-start enabled`n" } else { "" }) +
            "`nDo you want to test the launcher now?",
            'Installation Complete',
            'YesNo',
            'Information'
        )

        if ($result -eq 'Yes') {
            Start-Process -FilePath $batchPath
        }

    } catch {
        $statusLabel.Text = "Installation failed: $($_.Exception.Message)"
        $statusLabel.ForeColor = [System.Drawing.Color]::Red
        [System.Windows.Forms.MessageBox]::Show("Installation failed:`n`n$($_.Exception.Message)", 'Error', 'OK', 'Error')
    } finally {
        $installButton.Enabled = $true
        $cancelButton.Enabled = $true
    }
})
$form.Controls.Add($installButton)

# Cancel Button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(490, $yPos)
$cancelButton.Size = New-Object System.Drawing.Size(90, 35)
$cancelButton.Text = 'Close'
$cancelButton.Add_Click({
    $form.Close()
})
$form.Controls.Add($cancelButton)

# Show the form
[void]$form.ShowDialog()

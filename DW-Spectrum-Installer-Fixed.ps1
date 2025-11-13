# DW Spectrum Multi-Monitor Installer - FIXED VERSION
# GUI application to configure and install DW Spectrum launcher
# This version fixes PowerShell syntax errors and ensures proper field visibility

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'DW Spectrum Multi-Monitor Setup'
$form.Size = New-Object System.Drawing.Size(600, 800)
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

# Starting Y position for controls
[int]$yPos = 100

# Server IP Label and TextBox
$serverIPLabel = New-Object System.Windows.Forms.Label
$serverIPLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$serverIPLabel.Size = New-Object System.Drawing.Size(150, 20)
$serverIPLabel.Text = 'Server IP Address:'
$form.Controls.Add($serverIPLabel)

$serverIPBox = New-Object System.Windows.Forms.TextBox
$serverIPBox.Location = New-Object System.Drawing.Point(180, $yPos)
$serverIPBox.Size = New-Object System.Drawing.Size(200, 20)
$serverIPBox.Text = ''
$form.Controls.Add($serverIPBox)

$yPos = $yPos + 35

# Server Port Label and TextBox
$serverPortLabel = New-Object System.Windows.Forms.Label
$serverPortLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$serverPortLabel.Size = New-Object System.Drawing.Size(150, 20)
$serverPortLabel.Text = 'Server Port:'
$form.Controls.Add($serverPortLabel)

$serverPortBox = New-Object System.Windows.Forms.TextBox
$serverPortBox.Location = New-Object System.Drawing.Point(180, $yPos)
$serverPortBox.Size = New-Object System.Drawing.Size(200, 20)
$serverPortBox.Text = ''
$form.Controls.Add($serverPortBox)

$yPos = $yPos + 35

# Username Label and TextBox
$usernameLabel = New-Object System.Windows.Forms.Label
$usernameLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$usernameLabel.Size = New-Object System.Drawing.Size(150, 20)
$usernameLabel.Text = 'Username:'
$form.Controls.Add($usernameLabel)

$usernameBox = New-Object System.Windows.Forms.TextBox
$usernameBox.Location = New-Object System.Drawing.Point(180, $yPos)
$usernameBox.Size = New-Object System.Drawing.Size(200, 20)
$usernameBox.Text = ''
$form.Controls.Add($usernameBox)

$yPos = $yPos + 35

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
    if ($this.Checked) {
        $passwordBox.PasswordChar = [char]0
    } else {
        $passwordBox.PasswordChar = '*'
    }
}.GetNewClosure())
$form.Controls.Add($showPasswordCheck)

$yPos = $yPos + 35

# Separator
$separator2 = New-Object System.Windows.Forms.Label
$separator2.Location = New-Object System.Drawing.Point(20, $yPos)
$separator2.Size = New-Object System.Drawing.Size(560, 2)
$separator2.BorderStyle = 'Fixed3D'
$form.Controls.Add($separator2)

$yPos = $yPos + 15

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

$yPos = $yPos + 35

# Layout Names Section
$layoutsLabel = New-Object System.Windows.Forms.Label
$layoutsLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$layoutsLabel.Size = New-Object System.Drawing.Size(560, 20)
$layoutsLabel.Text = 'Layout Names:'
$layoutsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($layoutsLabel)

$yPos = $yPos + 25

# Help text for layouts
$layoutHelpLabel = New-Object System.Windows.Forms.Label
$layoutHelpLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$layoutHelpLabel.Size = New-Object System.Drawing.Size(560, 30)
$layoutHelpLabel.Text = "Enter layout names that match your saved DW Spectrum layouts.`nIf layouts don't exist yet, blank windows will open with setup instructions."
$layoutHelpLabel.ForeColor = [System.Drawing.Color]::Gray
$layoutHelpLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$form.Controls.Add($layoutHelpLabel)

$yPos = $yPos + 35

# Store the starting Y position for layouts
[int]$layoutStartY = $yPos

# Create layout textboxes dynamically based on monitor count
$script:layoutBoxes = @()
for ($i = 0; $i -lt 6; $i++) {
    # Calculate Y position for this layout field
    [int]$currentLayoutY = $layoutStartY + ($i * 30)

    # Create label
    $layoutLabel = New-Object System.Windows.Forms.Label
    $layoutLabel.Location = New-Object System.Drawing.Point(20, $currentLayoutY)
    $layoutLabel.Size = New-Object System.Drawing.Size(150, 20)
    $layoutLabel.Text = "Monitor $($i + 1) Layout:"
    $layoutLabel.Visible = $false  # Start hidden, will show based on monitor count
    $form.Controls.Add($layoutLabel)

    # Create textbox
    $layoutBox = New-Object System.Windows.Forms.TextBox
    $layoutBox.Location = New-Object System.Drawing.Point(180, $currentLayoutY)
    $layoutBox.Size = New-Object System.Drawing.Size(200, 20)
    $layoutBox.Visible = $false  # Start hidden, will show based on monitor count
    # NO default values - user must enter their actual layout names
    $layoutBox.Text = ''

    $form.Controls.Add($layoutBox)

    # Store references in script-scoped array
    $script:layoutBoxes += @{Label = $layoutLabel; TextBox = $layoutBox}
}

# Function to update layout field visibility
function Update-LayoutVisibility {
    $count = [int]$monitorsCombo.SelectedItem
    for ($i = 0; $i -lt 6; $i++) {
        if ($i -lt $count) {
            $script:layoutBoxes[$i].Label.Visible = $true
            $script:layoutBoxes[$i].TextBox.Visible = $true
        } else {
            $script:layoutBoxes[$i].Label.Visible = $false
            $script:layoutBoxes[$i].TextBox.Visible = $false
        }
    }
}

# Update visible layout boxes when monitor count changes
$monitorsCombo.Add_SelectedIndexChanged({
    Update-LayoutVisibility
})

# Initialize visibility for default selection (2 monitors)
Update-LayoutVisibility

# Move Y position down past all possible layout fields
$yPos = $layoutStartY + 200

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

# Browse button for path selection
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

$yPos = $yPos + 35

# Auto-start checkbox
$autoStartCheck = New-Object System.Windows.Forms.CheckBox
$autoStartCheck.Location = New-Object System.Drawing.Point(20, $yPos)
$autoStartCheck.Size = New-Object System.Drawing.Size(300, 20)
$autoStartCheck.Text = 'Enable auto-start on Windows login'
$autoStartCheck.Checked = $true
$form.Controls.Add($autoStartCheck)

$yPos = $yPos + 35

# Status Label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, $yPos)
$statusLabel.Size = New-Object System.Drawing.Size(560, 40)
$statusLabel.Text = ''
$statusLabel.ForeColor = [System.Drawing.Color]::Blue
$form.Controls.Add($statusLabel)

$yPos = $yPos + 50

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
        if ([string]::IsNullOrWhiteSpace($script:layoutBoxes[$i].TextBox.Text)) {
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
            $scriptContent += "`n`$monitor$($i + 1)Layout = `"$($script:layoutBoxes[$i].TextBox.Text)`""
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

# Try to launch with the specified layout name
# If the layout doesn't exist, DW Spectrum will open with a blank/default view
# The user can then arrange cameras and save the layout with the correct name

`$arguments$monNum = @(
    "--no-single-application",
    "--auth=`$authString",
    "--screen=$i",
    "--no-client-update"
)

# Add layout name parameter if it's specified and not empty
if (-not [string]::IsNullOrWhiteSpace(`$monitor${monNum}Layout)) {
    `$arguments$monNum += "--layout-name=```"`$monitor${monNum}Layout```""
    Write-Host "  Layout: `$monitor${monNum}Layout" -ForegroundColor Gray
} else {
    Write-Host "  No layout specified - opening blank window" -ForegroundColor Yellow
}

Start-Process -FilePath `$dwSpectrumPath -ArgumentList `$arguments$monNum

"@
            if ($i -lt $monitorCount - 1) {
                $scriptContent += "# Wait before launching next instance`nStart-Sleep -Seconds 2`n"
            }
        }

        $scriptContent += @"

Write-Host ""
Write-Host "All instances launched successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FIRST TIME SETUP INSTRUCTIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "If your layouts don't appear (blank windows):" -ForegroundColor Yellow
Write-Host "  1. Arrange cameras in each window as desired" -ForegroundColor White
Write-Host "  2. Click Main Menu (top-left hamburger icon)" -ForegroundColor White
Write-Host "  3. Select 'Save Windows Configuration'" -ForegroundColor White
Write-Host "  4. Enter the layout name EXACTLY as specified:" -ForegroundColor White
"@
        # Add the layout names to the instructions
        for ($i = 0; $i -lt $monitorCount; $i++) {
            $monNum = $i + 1
            $layoutName = $script:layoutBoxes[$i].TextBox.Text
            if (-not [string]::IsNullOrWhiteSpace($layoutName)) {
                $scriptContent += "`n"
                $scriptContent += "Write-Host `"     Monitor ${monNum}: ${layoutName}`" -ForegroundColor Cyan"
            }
        }

        $scriptContent += @"

Write-Host ""
Write-Host "  5. Click Save" -ForegroundColor White
Write-Host "  6. Repeat for each monitor" -ForegroundColor White
Write-Host ""
Write-Host "Next time you run this launcher, your layouts will load automatically!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
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

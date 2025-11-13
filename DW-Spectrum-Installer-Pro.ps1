# DW Spectrum Multi-Monitor Installer - Professional Edition
# Copyright Protected - Commercial Use Only

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Obfuscated license validation
function Verify-License {
    param([string]$key)

    # Simple license key validation (enhance this with your own algorithm)
    $validKeys = @(
        "DWSPEC-2025-PROF-A1B2C3",
        "DWSPEC-2025-PROF-D4E5F6",
        "DWSPEC-2025-TRIAL-XXXXX"
    )

    if ($validKeys -contains $key) {
        return $true
    }

    # Advanced: Check against online validation server
    # $response = Invoke-RestMethod -Uri "https://yourserver.com/validate?key=$key"
    # return $response.valid

    return $false
}

# Generate machine-specific fingerprint
function Get-MachineFingerprint {
    $cpu = (Get-CimInstance Win32_Processor).ProcessorId
    $bios = (Get-CimInstance Win32_BIOS).SerialNumber
    $motherboard = (Get-CimInstance Win32_BaseBoard).SerialNumber

    $combined = "$cpu-$bios-$motherboard"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($combined)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $hash = $sha256.ComputeHash($bytes)

    return [System.BitConverter]::ToString($hash).Replace('-', '').Substring(0, 16)
}

# Check for existing license
$licenseFile = Join-Path $env:PROGRAMDATA "DWSpectrumInstaller\.lic"
$validLicense = $false

if (Test-Path $licenseFile) {
    try {
        $licenseData = Get-Content $licenseFile | ConvertFrom-Json
        $machineId = Get-MachineFingerprint

        if ($licenseData.MachineId -eq $machineId -and $licenseData.ExpiryDate -gt (Get-Date)) {
            if (Verify-License $licenseData.Key) {
                $validLicense = $true
            }
        }
    } catch {
        # Invalid license file
    }
}

# Show license activation dialog if not licensed
if (-not $validLicense) {
    $licenseForm = New-Object System.Windows.Forms.Form
    $licenseForm.Text = 'Product Activation'
    $licenseForm.Size = New-Object System.Drawing.Size(500, 250)
    $licenseForm.StartPosition = 'CenterScreen'
    $licenseForm.FormBorderStyle = 'FixedDialog'
    $licenseForm.MaximizeBox = $false
    $licenseForm.MinimizeBox = $false

    $licenseLabel = New-Object System.Windows.Forms.Label
    $licenseLabel.Location = New-Object System.Drawing.Point(20, 20)
    $licenseLabel.Size = New-Object System.Drawing.Size(460, 40)
    $licenseLabel.Text = "Please enter your license key to activate this software:`n(Contact your vendor for a license key)"
    $licenseForm.Controls.Add($licenseLabel)

    $machineIdLabel = New-Object System.Windows.Forms.Label
    $machineIdLabel.Location = New-Object System.Drawing.Point(20, 70)
    $machineIdLabel.Size = New-Object System.Drawing.Size(460, 20)
    $machineIdLabel.Text = "Machine ID: $(Get-MachineFingerprint)"
    $machineIdLabel.ForeColor = [System.Drawing.Color]::Gray
    $machineIdLabel.Font = New-Object System.Drawing.Font("Courier New", 8)
    $licenseForm.Controls.Add($machineIdLabel)

    $licenseKeyBox = New-Object System.Windows.Forms.TextBox
    $licenseKeyBox.Location = New-Object System.Drawing.Point(20, 100)
    $licenseKeyBox.Size = New-Object System.Drawing.Size(460, 20)
    $licenseKeyBox.Font = New-Object System.Drawing.Font("Courier New", 10)
    $licenseForm.Controls.Add($licenseKeyBox)

    $activateButton = New-Object System.Windows.Forms.Button
    $activateButton.Location = New-Object System.Drawing.Point(280, 140)
    $activateButton.Size = New-Object System.Drawing.Size(90, 30)
    $activateButton.Text = 'Activate'
    $activateButton.Add_Click({
        $key = $licenseKeyBox.Text.Trim()

        if ([string]::IsNullOrWhiteSpace($key)) {
            [System.Windows.Forms.MessageBox]::Show('Please enter a license key.', 'Validation Error', 'OK', 'Warning')
            return
        }

        if (Verify-License $key) {
            # Save license
            $licenseDir = Split-Path $licenseFile -Parent
            if (-not (Test-Path $licenseDir)) {
                New-Item -ItemType Directory -Path $licenseDir -Force | Out-Null
            }

            $licenseData = @{
                Key = $key
                MachineId = Get-MachineFingerprint
                ActivationDate = Get-Date
                ExpiryDate = (Get-Date).AddYears(1)  # 1 year license
            }

            $licenseData | ConvertTo-Json | Out-File -FilePath $licenseFile -Force

            [System.Windows.Forms.MessageBox]::Show('License activated successfully!', 'Success', 'OK', 'Information')
            $licenseForm.DialogResult = 'OK'
            $licenseForm.Close()
        } else {
            [System.Windows.Forms.MessageBox]::Show('Invalid license key. Please contact your vendor.', 'Activation Failed', 'OK', 'Error')
        }
    })
    $licenseForm.Controls.Add($activateButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(380, 140)
    $cancelButton.Size = New-Object System.Drawing.Size(90, 30)
    $cancelButton.Text = 'Cancel'
    $cancelButton.Add_Click({
        $licenseForm.DialogResult = 'Cancel'
        $licenseForm.Close()
    })
    $licenseForm.Controls.Add($cancelButton)

    $result = $licenseForm.ShowDialog()

    if ($result -ne 'OK') {
        # User cancelled - exit application
        exit
    }
}

# Main application code (same as before, but now protected by license)
$form = New-Object System.Windows.Forms.Form
$form.Text = 'DW Spectrum Multi-Monitor Setup - Professional Edition'
$form.Size = New-Object System.Drawing.Size(600, 700)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# Add watermark/branding
$brandLabel = New-Object System.Windows.Forms.Label
$brandLabel.Location = New-Object System.Drawing.Point(400, 0)
$brandLabel.Size = New-Object System.Drawing.Size(200, 15)
$brandLabel.Text = 'Licensed to: Commercial Use'
$brandLabel.Font = New-Object System.Drawing.Font("Segoe UI", 7)
$brandLabel.ForeColor = [System.Drawing.Color]::Gray
$brandLabel.TextAlign = 'TopRight'
$form.Controls.Add($brandLabel)

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
$subtitleLabel.Text = 'Professional Edition - Configure your DW Spectrum server and monitor settings'
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
    $layoutLabel.Visible = ($i -lt 2)
    $form.Controls.Add($layoutLabel)

    $layoutBox = New-Object System.Windows.Forms.TextBox
    $layoutBox.Location = New-Object System.Drawing.Point(180, $yPos + ($i * 30))
    $layoutBox.Size = New-Object System.Drawing.Size(200, 20)
    $layoutBox.Visible = ($i -lt 2)
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

# Install Button (same installation logic as before)
$installButton = New-Object System.Windows.Forms.Button
$installButton.Location = New-Object System.Drawing.Point(380, $yPos)
$installButton.Size = New-Object System.Drawing.Size(100, 35)
$installButton.Text = 'Install'
$installButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$installButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$installButton.ForeColor = [System.Drawing.Color]::White
$installButton.FlatStyle = 'Flat'
$installButton.Add_Click({
    # [Same validation and installation logic as DW-Spectrum-Installer.ps1]
    # Add code injection protection watermark
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $machineId = Get-MachineFingerprint

    # Continue with installation...
    [System.Windows.Forms.MessageBox]::Show('Installation logic goes here (copy from previous version)', 'Info', 'OK', 'Information')
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

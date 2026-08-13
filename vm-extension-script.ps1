# Set some defaults
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$LogFile = Join-Path -Path ($env:ProgramData) -ChildPath "Labsetup.log"

# Functions
function Write-Log {
    param (
        [string]$Value,
        [string]$Level = "Info",
        [string]$Path = $LogFile
    )
    Add-Content -Path $Path -Value "[$($Level)] - [$(Get-Date)] - $Value" -Force
}

# Disable Server Manager
try {
    Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -Value 1 -Force
    Write-Log -Value "Disabled Server Manager"
} catch {
    Write-Log -Value "Could not disable Server Manager" -Level "Error"
    Write-Log -Value $_ -Level "Error"
}

# Disable IE ESC
try {
    Set-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -Name 'IsInstalled' -Value 0
    Write-Log -Value "Disabled IE ESC"
} catch {
    Write-Log -Value "Could not disable IE ESC" -Level "Error"
    Write-Log -Value $_ -Level "Error"
}

# Download Storage Explorer
try {
    Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2216182&clcid=0x409" -UseBasicParsing -OutFile "$($env:ProgramData)\StorageExplorer.exe"
    Write-Log -Value "Downloaded Storage Explorer"
}
catch {
    Write-Log -Value "Could not download Storage Explorer" -Level "Error"
    Write-Log -Value $_ -Level "Error"
}

# Install Storage Explorer
try {
    Start-Process -FilePath "$($env:ProgramData)\StorageExplorer.exe" -ArgumentList @('/VERYSILENT','/NORESTART','/ALLUSERS') -Wait
    Write-Log -Value "Installed Storage Explorer"
}
catch {
    Write-Log -Value "Could not Install Storage Explorer" -Level "Error"
    Write-Log -Value $_ -Level "Error"
}

# Create Storage Explorer Shortcut on Desktop
try {
    Copy-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Azure Storage Explorer\Microsoft Azure Storage Explorer.lnk" "C:\Users\Public\Desktop" -Force
    Write-Log -Value "Created Storage Explorer Shortcut on Desktop"
}
catch {
    Write-Log -Value "Could not Create Storage Explorer Shortcut" -Level "Error"
    Write-Log -Value $_ -Level "Error"
}

# Download the Images
try {
    $url = "https://github.com/pluralsight-cloud/AZ-500-Microsoft-Azure-Security-Technologies/raw/main/1323%20-%20AZ-500%20Secure%20Compute,%20Storage,%20and%20Databases/Labs/Configuration%20and%20Security%20of%20Azure%20Storage%20Accounts/Files.zip"
    $zipfile = "$($env:ProgramData)\Files.zip"
    $folder = "C:\images"
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $zipfile
    Write-Log -Value "Downloaded sample images"
    Expand-Archive -Path $zipfile -DestinationPath $folder -Force
    Write-Log -Value "Unzipped sample images"
    Remove-Item -Path $zipfile -Force
    Write-Log -Value "Removed sample images zip file"
}
catch {
    Write-Log -Value "Could not download sample images" -Level "Error"
    Write-Log -Value $_ -Level "Error"
}

# Clean-up Edge
## Create the Directory Tree
New-Item -Path "HKLM:\Software\Policies\Microsoft\Edge\PasswordManagerEnabled" -Force
New-Item -Path "HKLM:\Software\Policies\Microsoft\Edge\RestoreOnStartupURLs" -Force
# Disable full-tab promotional content
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "PromotionalTabsEnabled" -Value 0 -Type "DWord" -Force
## Disable Password Manager
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Edge\PasswordManagerEnabled" -Name "PromotionalTabsEnabled" -Value 0 -Type "DWord" -Force
## Disallow importing of browser settings
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "ImportBrowserSettings" -Value 0 -Force
## Disallow Microsoft News content on the new tab page
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "NewTabPageContentEnabled" -Value 0 -Type "DWord" -Force
## Disallow all background types allowed for the new tab page layout
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "NewTabPageAllowedBackgroundTypes" -Value 3 -Type "DWord" -Force
## Hide App Launcher on Microsoft Edge new tab page
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "NewTabPageAppLauncherEnabled" -Value 0 -Type "DWord" -Force
## Disable the password manager
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "PasswordManagerEnabled" -Value '0' -Force
## Hide the First-run experience and splash screen
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "HideFirstRunExperience" -Value 1 -Force
## Disable sign-in
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "BrowserSignin" -Value 0 -Force
## Disable quick links on the new tab page
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "NewTabPageQuickLinksEnabled" -Value 0 -Force
## Disable importing of favorites
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "ImportFavorites" -Value 0 -Force

# Install IIS
Add-WindowsFeature Web-Server -IncludeManagementTools

# Set Webserver content
Remove-Item 'C:\inetpub\wwwroot\iisstart.htm'
Add-Content -Path "C:\inetpub\wwwroot\iisstart.htm" -Value $("<h1>Hello from " + $env:computername + "</h1>")
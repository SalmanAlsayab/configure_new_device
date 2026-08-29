# Trust the repository to bypass confirmation prompts
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

$moduleName = "PSWindowsUpdate"

# If the module is already loaded in this session, remove it before reinstalling.
Get-Module -Name $moduleName -All | Remove-Module -Force -ErrorAction SilentlyContinue

# If an older version is already installed, remove it so the install can proceed.
Uninstall-Module -Name $moduleName -AllVersions -Force -ErrorAction SilentlyContinue

# Install the Windows Update module
Install-Module -Name $moduleName -Force -Scope CurrentUser -AllowClobber

# Import it into your current session
Import-Module $moduleName -Force

Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot

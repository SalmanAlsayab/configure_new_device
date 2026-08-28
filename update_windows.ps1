# Trust the repository to bypass confirmation prompts
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# Install the Windows Update module
Install-Module -Name PSWindowsUpdate -Force

# Import it into your current session
Import-Module PSWindowsUpdate

Get-WindowsUpdate -AcceptAll -Install -AutoReboot

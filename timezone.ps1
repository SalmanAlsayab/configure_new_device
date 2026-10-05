# 1. Enable the Time Zone Auto Update service
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value 3

# 2. Allow system-wide location access for time zone detection
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Allow"

# 3. Force the service to start immediately 
Start-Service -Name "tzautoupdate" -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

# 1. Configure the Windows Time service to start automatically
Set-Service -Name "w32time" -StartupType Automatic

# 2. Start the Windows Time service if it is stopped
Start-Service -Name "w32time" -ErrorAction SilentlyContinue

# 3. Configure the system to sync from configured NTP servers
w32tm /config /syncfromflags:manual /update

# 4. Force an immediate clock synchronization
w32tm /resync

Start-Sleep -Seconds 2
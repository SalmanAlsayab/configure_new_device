$hostname = Read-Host -Prompt "Please enter new hostname: "

Write-Output "host name changed to $hostname"

Rename-Computer -NewName $hostname

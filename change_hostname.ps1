$hostname = Read-Host -Prompt "Please enter your name"

Rename-Computer -NewName $hostname -Restart

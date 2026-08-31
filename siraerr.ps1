$scriptPath = $PSScriptRoot

$siraerr = Join-Path $scriptPath "VC_redist.x64.exe"

$wshell = New-Object -ComObject WScript.Shell
# start the process
Start-Process -FilePath $siraerr -ArgumentList "/norestart" -PassThru

# wait then TAb to policy agreement checkbox
Start-Sleep -Seconds 5
$wshell.SendKeys("{TAB}")
# press SPACE to tick the checkbox
Start-Sleep -Milliseconds 50
$wshell.SendKeys(" ")
# TAB for install button
Start-Sleep -Milliseconds 50
$wshell.SendKeys("{TAB}")
# press ENTER to install
Start-Sleep -Milliseconds 50
$wshell.SendKeys("~")

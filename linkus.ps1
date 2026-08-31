$scriptPath = $PSScriptRoot

$linkus = Join-Path $scriptPath "Linkus-desktop-win-setup.exe"

# 2. Add UI Automation Assembly
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

$wshell = New-Object -ComObject WScript.Shell
# execute linkus installer
$process = Start-Process -FilePath $linkus -ArgumentList "/norestart" -PassThru

Start-Sleep -Milliseconds 2000
# bring linkus to foreground
$Desktop = [System.Windows.Automation.AutomationElement]::RootElement
$Condition = New-Object System.Windows.Automation.PropertyCondition(
    [System.Windows.Automation.AutomationElement]::NameProperty, "Linkus Desktop Client"
)
$SettingsWindow = $Desktop.FindFirst([System.Windows.Automation.TreeScope]::Children, $Condition)

Start-Sleep -Milliseconds 500
# press ALT + a to make it accessable for all users
$wshell.SendKeys("%{a}")
Start-Sleep -Milliseconds 500
#press enter for next
$wshell.SendKeys("~")


Start-Sleep -Milliseconds 500
# press enter for install
$wshell.SendKeys("~")

Start-Sleep -Seconds 10
# press enter to finish
$wshell.SendKeys("~")
Start-Sleep -Seconds 4

# if security panel appeared navigate to press yes
$wshell.SendKeys("{TAB}")
Start-Sleep -Milliseconds 50
$wshell.SendKeys("{TAB}")
$wshell.SendKeys("~")

$scriptpath = $PSScriptRoot
$envpath = Join-Path -Path $scriptpath -ChildPath .env
# 1. Read the file line by line
Get-Content $envpath | 
# 2. Filter out empty lines and comment lines starting with #
Where-Object { $_ -and $_ -notmatch '^\s*#' } | 
# 3. Split each line by the first '=' character and set the variable
ForEach-Object { 
    $name, $value = $_ -split '=', 2
    if ($name) {
        Set-Content "env:\$($name.Trim())" $value.Trim()
    }
}

# 2. Add UI Automation Assembly
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

$wshell = New-Object -ComObject WScript.Shell

Start-Process "ms-settings:workplace"
Start-Sleep -Seconds 5

# 3. Locate the System Settings Window
$Desktop = [System.Windows.Automation.AutomationElement]::RootElement
$Condition = New-Object System.Windows.Automation.PropertyCondition(
    [System.Windows.Automation.AutomationElement]::NameProperty, "Settings"
)
$SettingsWindow = $Desktop.FindFirst([System.Windows.Automation.TreeScope]::Children, $Condition)

if ($SettingsWindow) {
    # 4. Find the "Connect" button by name
    $ButtonCondition = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::NameProperty, "Connect"
    )
    $ConnectButton = $SettingsWindow.FindFirst([System.Windows.Automation.TreeScope]::Subtree, $ButtonCondition)

    # 5. Trigger the Click action
    if ($ConnectButton) {
        $InvokePattern = $ConnectButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
        $InvokePattern.Invoke()
    }
    else {
        Write-Warning "Connect button not found. Ensure the page has fully loaded."
    }
}
else {
    Write-Warning "Settings window not found."
}

Start-Sleep -Seconds 10
# navigate to Entra ID
$wshell.SendKeys("{TAB}")
Start-Sleep -Milliseconds 50

# press ENTER
$wshell.SendKeys("~")
Start-Sleep -Seconds 5

# input Domain name
$wshell.SendKeys("$env:domain_name")
Start-Sleep -Milliseconds 50

# press ENTER
$wshell.SendKeys("~")
Start-Sleep -Seconds 5

# input Domain password
$wshell.SendKeys("$env:domain_password")
Start-Sleep -Milliseconds 50

# press ENTER
$wshell.SendKeys("~")
Start-Sleep -Seconds 15

# TAB to navigate to join
$wshell.SendKeys("{TAB}")
Start-Sleep -Milliseconds 50

$wshell.SendKeys("~")
Start-Sleep -Seconds 60

# TAB to navigate to DONE
$wshell.SendKeys("{TAB}")
Start-Sleep -Milliseconds 50

$wshell.SendKeys("~")
Start-Sleep -Seconds 1


start-sleep -Seconds 5
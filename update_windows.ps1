# Load UIA libraries
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

function Get-UpdateButton {
    param(
        [System.Windows.Automation.AutomationElement]$RootElement
    )

    $buttonCondition = [System.Windows.Automation.PropertyCondition]::new(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::Button
    )

    $buttons = $RootElement.FindAll([System.Windows.Automation.TreeScope]::Descendants, $buttonCondition)

    foreach ($button in $buttons) {
        $id = [string]$button.Current.AutomationId
        $name = [string]$button.Current.Name
        $combined = "$id|$name"

        if ($combined -match "CheckForUpdatesButton|CheckForUpdates|Check for updates|Check for Updates|Download|Install|Update now") {
            return $button
        }
    }

    return $null
}

# Launch Windows Update settings
Start-Process "ms-settings:windowsupdate"
Start-Sleep -Seconds 5

# Find the Settings/Windows Update window in a more tolerant way
$root = [System.Windows.Automation.AutomationElement]::RootElement
$settingsWindow = $null

$windowConditions = @(
    "Settings",
    "Windows Update",
    "Windows Update settings"
)

foreach ($title in $windowConditions) {
    $settingsWindow = $root.FindFirst(
        [System.Windows.Automation.TreeScope]::Descendants,
        [System.Windows.Automation.PropertyCondition]::new(
            [System.Windows.Automation.AutomationElement]::NameProperty,
            $title
        )
    )

    if ($settingsWindow) { break }
}

if (-not $settingsWindow) {
    $settingsWindow = $root.FindFirst(
        [System.Windows.Automation.TreeScope]::Descendants,
        [System.Windows.Automation.PropertyCondition]::new(
            [System.Windows.Automation.AutomationElement]::ClassNameProperty,
            "ApplicationFrameWindow"
        )
    )
}

if ($settingsWindow) {
    $updateButton = Get-UpdateButton -RootElement $settingsWindow

    if ($updateButton) {
        $buttonName = $updateButton.Current.Name
        Write-Host "Current Button State: $buttonName" -ForegroundColor Cyan

        switch ($buttonName) {
            { $_ -match "Check for updates" } {
                Write-Host "Action: System is idle. Triggering check..."
                $invokePattern = $updateButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
                $invokePattern.Invoke()
            }
            { $_ -match "Download|Install|Update now" } {
                Write-Host "Action: Updates are ready to download/install. Triggering action..."
                $invokePattern = $updateButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
                $invokePattern.Invoke()
            }
            default {
                $id = $updateButton.Current.AutomationId
                if ($id -match "CheckForUpdatesButton|CheckForUpdates|Check for updates") {
                    Write-Host "Action: Found the update button. Triggering it..."
                    $invokePattern = $updateButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
                    $invokePattern.Invoke()
                }
                else {
                    Write-Host "Action: Button is currently in state '$buttonName'. No action taken." -ForegroundColor Yellow
                }
            }
        }
    }
    else {
        Write-Warning "Could not find the update button in the Settings/Windows Update window. Try increasing the wait time or checking the current page layout."
    }
}
else {
    Write-Warning "Settings window could not be found."
}

Start-Sleep -Seconds 5
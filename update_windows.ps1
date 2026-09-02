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

        if ($combined -match "CheckForUpdatesButton|CheckForUpdates|Check for updates|Check for Updates|Download|Install|Update now|Download & install all") {
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
    Write-Host "Settings window found successfully" -ForegroundColor Green
    Start-Sleep -Seconds 2  # Let the page fully render
    
    for ($i = 1; $i -le 20; $i++) {
        Write-Host "`nAttempt $i to find and click update button..." -ForegroundColor Cyan

        $updateButton = Get-UpdateButton -RootElement $settingsWindow

        if ($updateButton) {
            $buttonName = $updateButton.Current.Name
            Write-Host "Current Button State: $buttonName" -ForegroundColor Cyan

            if ($buttonName -like "*Download*" -or
                $buttonName -like "*Install*" -or
                $buttonName -like "*Update*" -or
                $buttonName -like "*Download & install all*") {
                Write-Host "Action: Updates are ready to download/install. Triggering action..." -ForegroundColor Green
                $invokePattern = $updateButton.GetCurrentPattern(
                    [System.Windows.Automation.InvokePattern]::Pattern
                )
                $invokePattern.Invoke()
            }
            elseif ($buttonName -match "CheckForUpdatesButton|CheckForUpdates|Check for updates") {
                Write-Host "Action: Found the update button. Triggering it..." -ForegroundColor Green
                $invokePattern = $updateButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
                $invokePattern.Invoke()
            }
            else {
                Write-Host "Action: Button is currently in state '$buttonName'. No action taken." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Could not find the update button. Waiting before retry..." -ForegroundColor Yellow
        }
        Start-Sleep -Seconds 8
    }
}
else {
    Write-Host "Settings window could not be found after all attempts." -ForegroundColor Red
}


Start-Sleep -Seconds 5
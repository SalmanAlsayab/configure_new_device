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

        if ($combined -match "Advanced options") {
            return $button
        }
    }

    return $null
}
function Get-Optionalupdates {
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

        if ($combined -match "Optional updates") {
            return $button
        }
    }

    return $null
}

function Get-downloadOp {
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

        if ($combined -match "Download & install") {
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
    
    $updateButton = Get-UpdateButton -RootElement $settingsWindow

    if ($updateButton) {
        $buttonName = $updateButton.Current.Name
        Write-Host "Current Button State: $buttonName" -ForegroundColor Cyan

        if ($buttonName -match "Advanced options") {
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
    }

    Start-Sleep -Seconds 3
    $optionalButton = Get-Optionalupdates -RootElement $settingsWindow
    # 1. Find the "Optional updates" button/listItem element

    if ($optionalButton) {
        Write-Host "Found Optional Updates button. Clicking..." -ForegroundColor Green
            
        # 2. Invoke the click to open the Optional updates page
        $invokePattern = $optionalButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
        $invokePattern.Invoke()
            
        # 3. Pause for navigation to complete
        Start-Sleep -Seconds 2
    }

    $checkBoxCondition = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::CheckBox
    )
    $checkBoxes = $settingsWindow.FindAll(
        [System.Windows.Automation.TreeScope]::Descendants, $checkBoxCondition
    )

    Write-Host "Found $($checkBoxes.Count) checkbox(es)."

    # 3. Cycle through and check every unchecked checkbox using TogglePattern
    foreach ($cb in $checkBoxes) {
        $togglePattern = $null
        if ($cb.TryGetCurrentPattern([System.Windows.Automation.TogglePattern]::Pattern, [ref]$togglePattern)) {
            if ($togglePattern.Current.ToggleState -ne [System.Windows.Automation.ToggleState]::On) {
                $togglePattern.Toggle()
                Write-Host "Checked: $($cb.Current.Name)"
            }
        }
    }

    # Short pause for UI state update
    Start-Sleep -Milliseconds 500

    $downloadOp = Get-downloadOp -RootElement $settingsWindow
    # 1. Find the "Optional updates" button/listItem element

    if ($downloadOp) {
        Write-Host "Found Optional Updates button. Clicking..." -ForegroundColor Green
            
        # 2. Invoke the click to open the Optional updates page
        $invokePattern = $downloadOp.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
        $invokePattern.Invoke()
            
        # 3. Pause for navigation to complete
        Start-Sleep -Seconds 2
    }

}


Start-Sleep -Seconds 5
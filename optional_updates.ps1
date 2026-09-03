Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes


$wshell = New-Object -ComObject WScript.Shell

function Get-AdvancedButton {
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
    Start-Process "ms-settings:windowsupdate"
    Start-Sleep -Seconds 5
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
    Start-Sleep -Seconds 5  # Let the page fully render
    
    $advancedButton = Get-AdvancedButton -RootElement $settingsWindow

    
    if (-not $advancedButton) {
        Start-Process "ms-settings:windowsupdate"
        Start-Sleep -Seconds 5
        $settingsWindow = $root.FindFirst(
            [System.Windows.Automation.TreeScope]::Descendants,
            [System.Windows.Automation.PropertyCondition]::new(
                [System.Windows.Automation.AutomationElement]::ClassNameProperty,
                "ApplicationFrameWindow"
            )
        )
    }

    if ($advancedButton) {
        Write-Host "Action: Updates are ready to download/install. Triggering action..." -ForegroundColor Green
        $invokePattern = $advancedButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
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

$wshell.SendKeys("~")
Start-Sleep -Seconds 2

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



Start-Sleep -Seconds 5
# 1. Read the file line by line
Get-Content .env | 
# 2. Filter out empty lines and comment lines starting with #
Where-Object { $_ -and $_ -notmatch '^\s*#' } | 
# 3. Split each line by the first '=' character and set the variable
ForEach-Object { 
    $name, $value = $_ -split '=', 2
    if ($name) {
        Set-Content "env:\$($name.Trim())" $value.Trim()
    }
}

Start-Process "ms-settings:workplace"
Start-Sleep -Seconds 5
$wshell = New-Object -ComObject WScript.Shell

# Loop 11 times
# 1..12 | ForEach-Object {
#     $wshell.SendKeys("{TAB}")
#     Start-Sleep -Milliseconds 50  # Small delay between taps
# }

# Optional: Press Space to click the focused button
$wshell.SendKeys(" ")

Start-Sleep -Seconds 5

$wshell.SendKeys("$env:domain_name")
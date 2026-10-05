$scriptpath = Join-Path -Path $PSScriptRoot -ChildPath "passwords.json"

# Parse your JSON
$config = Get-Content -Path $scriptpath -Raw | ConvertFrom-Json

# Display the list with numbers
$num = 1
$properties = @($config.PSObject.Properties)

foreach ($prop in $properties) {
    Write-Host "$num- $($prop.Name)"
    $num++
}

Write-Host "" # Just adds a blank line for spacing

# Prompt the user for input
[int]$selection = Read-Host -Prompt "What is your current location? (Enter the number)"

# Verify and get the selected location name
if ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $properties.Count) {
    $selectedProp = $properties[$selection - 1]
    $locationName = $selectedProp.Name
    $ssid = $selectedProp.Value[0]
    $password = $selectedProp.Value[1]
    write-host "$ssid - $password"

    $xmlContent = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>$ssid</name>
    <SSIDConfig>
        <SSID>
            <name>$ssid</name>
        </SSID>
    </SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>auto</connectionMode>
    <MSM>
        <security>
            <authEncryption>
                <authentication>WPA2PSK</authentication>
                <encryption>AES</encryption>
                <useOneX>false</useOneX>
            </authEncryption>
            <sharedKey>
                <keyType>passPhrase</keyType>
                <protected>false</protected>
                <keyMaterial>$password</keyMaterial>
            </sharedKey>
        </security>
    </MSM>
</WLANProfile>
"@  

    $filePath = "$env:TEMP\wifi-profile.xml"
    $xmlContent | Set-Content -Path $filePath -Encoding Ascii

    # Add the profile to Windows
    netsh wlan add profile filename="$filePath"

    # Connect to the network
    netsh wlan connect ssid="$ssid" name="$ssid"

    # Clean up the temporary file
    Remove-Item -Path $filePath

    Write-Output "connected to $ssid wifi"

}
else {
    Write-Host "Invalid selection." -ForegroundColor Red
}



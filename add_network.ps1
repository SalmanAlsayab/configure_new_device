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

$xmlContent = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>$env:ssid</name>
    <SSIDConfig>
        <SSID>
            <name>$env:ssid</name>
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
                <keyMaterial>$env:password</keyMaterial>
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
netsh wlan connect ssid="$env:ssid" name="$env:ssid"

# Clean up the temporary file
Remove-Item -Path $filePath

Write-Output "connected to $env:ssid wifi"
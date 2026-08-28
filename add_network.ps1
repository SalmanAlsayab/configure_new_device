$ssid = 'meena-health'
$password = 'MH-HO@Loc1$321'

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
    <connectionMode>manual</connectionMode>
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

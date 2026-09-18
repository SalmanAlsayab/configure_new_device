#Requires -RunAsAdministrator

$scripts = @(
    'join_domain.ps1'
    'update_windows.ps1'
    'optional_updates.ps1'
)

$stagingPath = Join-Path -Path $env:TEMP -ChildPath "configure_new_device_$([guid]::NewGuid())"
New-Item -Path $stagingPath -ItemType Directory -Force | Out-Null

try {
    $filesToStage = @{
        '.env' = Join-Path -Path $PSScriptRoot -ChildPath '.env'
    }

    foreach ($script in $scripts) {
        $filesToStage[$script] = Join-Path -Path $PSScriptRoot -ChildPath $script
    }

    foreach ($file in $filesToStage.Keys) {
        $sourcePath = $filesToStage[$file]

        if (-not (Test-Path -Path $sourcePath -PathType Leaf)) {
            throw "Required file not found: $sourcePath"
        }

        Copy-Item -Path $sourcePath -Destination $stagingPath
    }

    Push-Location -Path $stagingPath
    Write-Output "You can remove the USB now"

    try {
        foreach ($script in $scripts) {
            Write-Output "Running $script"
            & (Join-Path -Path $stagingPath -ChildPath $script)

            if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
                throw "$script failed with exit code $LASTEXITCODE"
            }
        }
    }
    finally {
        Pop-Location
    }
}
finally {
    Remove-Item -Path $stagingPath -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output 'All configuration scripts completed.'

$Linkus_folder = "C:\Program Files (x86)\Linkus Desktop Client"
$Linkus_file = "Linkus Desktop Client.exe"

$Sirateck_folder = "C:\Fakeeh Tecknologies\Siratech.Hybrid.App" 
$Siratech_file = "YARWebApp.Win"

$match_linkus = Get-ChildItem -Path $Linkus_folder -Filter $Linkus_file -ErrorAction SilentlyContinue
$match_sirtech = Get-ChildItem -Path $Sirateck_folder -Filter $Siratech_file -ErrorAction SilentlyContinue
# check if all files are install from domain
while (!$match_linkus -and !$match_sirtech) {
    Start-Sleep -Seconds 2
    $match_linkus = Get-ChildItem -Path $Linkus_folder -Filter $Linkus_file -ErrorAction SilentlyContinue
    $match_sirtech = Get-ChildItem -Path $Sirateck_folder -Filter $Siratech_file -ErrorAction SilentlyContinue

}

Start-Sleep -Seconds 120

Restart-Computer -Force

$scripts = @(
    'add_network.ps1'
    'configure_admin.ps1'
    'change_hostname.ps1'
    'update_windows.ps1'
)

$stagingPath = Join-Path -Path $env:TEMP -ChildPath "configure_new_device_$([guid]::NewGuid())"
New-Item -Path $stagingPath -ItemType Directory -Force | Out-Null

try {
    $filesToStage = @{
        '.env' = Join-Path -Path $PSScriptRoot -ChildPath '..\.env'
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


Restart-Computer -Force

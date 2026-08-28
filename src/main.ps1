$scripts = @(
    'change_hostname.ps1'
    'add_network.ps1'
    'configure_admin.ps1'
    'update_windows.ps1'
)

foreach ($script in $scripts) {
    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath $script

    if (-not (Test-Path -Path $scriptPath -PathType Leaf)) {
        throw "Required script not found: $scriptPath"
    }

    Write-Output "Running $script"
    & $scriptPath

    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
        throw "$script failed with exit code $LASTEXITCODE"
    }
}

Write-Output 'All configuration scripts completed.'

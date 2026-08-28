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

Write-Output $env:password

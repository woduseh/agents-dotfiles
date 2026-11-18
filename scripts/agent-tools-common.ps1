# Shared by agent-doctor.ps1 and repo-run.ps1; no persistent environment changes.
function Add-AgentUserPath {
    # A running desktop app can retain PATH from before WinGet installed tools.
    foreach ($entry in ([Environment]::GetEnvironmentVariable('Path', 'User') -split ';')) {
        if (-not [string]::IsNullOrWhiteSpace($entry)) {
            $expanded = [Environment]::ExpandEnvironmentVariables($entry)
            if ($expanded -notin ($env:Path -split ';')) { $env:Path += ";$expanded" }
        }
    }
}

function Get-AgentProject {
    param([string]$ProjectPath)
    $project = Get-Item -LiteralPath $ProjectPath -ErrorAction Stop
    if (-not $project.PSIsContainer) { throw "ProjectPath must be a directory: $ProjectPath" }
    $pins = @(
        foreach ($name in @('.node-version', '.nvmrc')) {
            $file = Join-Path $project.FullName $name
            if (Test-Path -LiteralPath $file -PathType Leaf) {
                $version = (Get-Content -LiteralPath $file -Raw).Trim() -replace '^v', ''
                if ($version -notmatch '^\d+\.\d+\.\d+$') {
                    throw "Use an exact Node version (for example 26.10.0) in $file"
                }
                [pscustomobject]@{ File = $name; Version = $version }
            }
        }
    )
    if (@($pins | ForEach-Object { $_.Version } | Select-Object -Unique).Count -gt 1) {
        throw "Conflicting .node-version and .nvmrc in $($project.FullName)"
    }
    $version = if ($pins.Count) { $pins[0].Version } else { $null }
    [pscustomobject]@{
        Path = $project.FullName
        NodeVersion = $version
        VersionFiles = @($pins | ForEach-Object { $_.File })
    }
}

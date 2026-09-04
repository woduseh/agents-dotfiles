[CmdletBinding()]
param(
    [ValidateSet('Check', 'Export', 'Install')]
    [string]$Mode = 'Check',
    [switch]$Apply,
    [string]$HomePath = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$homeRoot = [IO.Path]::GetFullPath($HomePath)
$manifest = Import-PowerShellDataFile -LiteralPath (Join-Path $repoRoot 'manifest.psd1')
$backupRoot = Join-Path $homeRoot ".agents-dotfiles-backups/$(Get-Date -Format 'yyyyMMdd-HHmmss-fffffff')-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
$removedSkills = @($manifest.RemovedSkills)
foreach ($skill in @($manifest.Skills) + $removedSkills) {
    if ($skill -notmatch '^[a-z0-9-]{1,64}$') { throw "Invalid skill name: $skill" }
}
foreach ($skill in $removedSkills) {
    if ($manifest.Skills -contains $skill) { throw "Skill is both installed and removed: $skill" }
}

function Get-SkillPath {
    param([string]$InstallRoot, [string]$Skill)
    $root = [IO.Path]::GetFullPath((Join-Path $homeRoot $InstallRoot))
    $homePrefix = $homeRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    if (-not $root.StartsWith($homePrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Skill install root must be inside HomePath: $InstallRoot"
    }
    [IO.Path]::GetFullPath((Join-Path $root $Skill))
}

function Assert-NoLinks {
    param([string]$Path)
    $current = $Path
    while ($current) {
        if (Test-Path -LiteralPath $current) {
            $item = Get-Item -LiteralPath $current -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                throw "Refusing removal through a link: $current"
            }
        }
        $current = Split-Path -Parent $current
    }
}

function Remove-ManagedSkill {
    param([string]$InstallRoot, [string]$Skill)
    $target = Get-SkillPath $InstallRoot $Skill
    Assert-NoLinks (Split-Path -Parent $target)
    $item = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
    if ($null -eq $item) { return }
    if (-not $item.PSIsContainer) {
        throw "Expected a skill directory: $target"
    }
    $relative = [IO.Path]::GetRelativePath($homeRoot, $target)
    $backup = [IO.Path]::GetFullPath((Join-Path $backupRoot $relative))
    $backupPrefix = [IO.Path]::GetFullPath($backupRoot).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    if (-not $backup.StartsWith($backupPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Backup path escapes backup directory: $backup"
    }
    Assert-NoLinks $backup
    Write-Host "[REMOVE] Skill: $Skill -> backup $backup"
    if ($Apply) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $backup) -Force | Out-Null
        # Directory.Move relocates the directory entry, including a junction itself,
        # without traversing links or deleting their target contents.
        [IO.Directory]::Move($target, $backup)
    }
}

# Validate removal paths before any install writes.
foreach ($installRoot in $manifest.SkillInstallRoots) {
    foreach ($skill in $removedSkills) { $null = Get-SkillPath $installRoot $skill }
}

function Get-Hash {
    param([string]$Path)
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Get-TreeIndex {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return $null
    }

    $index = @{}
    foreach ($file in Get-ChildItem -LiteralPath $Path -Recurse -Force -File) {
        $relative = [IO.Path]::GetRelativePath($Path, $file.FullName).Replace('\', '/')
        $index[$relative] = Get-Hash $file.FullName
    }
    $index
}

function Test-SameFile {
    param([string]$Name, [string]$Local, [string]$Repository)

    if (-not (Test-Path -LiteralPath $Local -PathType Leaf) -or
        -not (Test-Path -LiteralPath $Repository -PathType Leaf)) {
        Write-Host "[MISSING] $Name"
        return $false
    }
    if ((Get-Hash $Local) -ne (Get-Hash $Repository)) {
        Write-Host "[DIFF] $Name"
        return $false
    }

    Write-Host "[OK] $Name"
    $true
}

function Test-SameTree {
    param([string]$Name, [string]$Local, [string]$Repository)

    $localIndex = Get-TreeIndex $Local
    $repositoryIndex = Get-TreeIndex $Repository
    if ($null -eq $localIndex -or $null -eq $repositoryIndex) {
        Write-Host "[MISSING] $Name"
        return $false
    }

    $allFiles = @($localIndex.Keys) + @($repositoryIndex.Keys) | Sort-Object -Unique
    $different = @($allFiles | Where-Object {
        -not $localIndex.ContainsKey($_) -or
        -not $repositoryIndex.ContainsKey($_) -or
        $localIndex[$_] -ne $repositoryIndex[$_]
    })
    if ($different.Count -gt 0) {
        Write-Host "[DIFF] $Name ($($different.Count) file(s))"
        return $false
    }

    Write-Host "[OK] $Name ($($localIndex.Count) file(s))"
    $true
}

function Backup-Existing {
    param([string]$Path, [string]$RelativePath)

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    $backup = Join-Path $backupRoot $RelativePath
    New-Item -ItemType Directory -Path (Split-Path -Parent $backup) -Force | Out-Null
    Copy-Item -LiteralPath $Path -Destination $backup -Recurse -Force
}

function Copy-OneFile {
    param(
        [string]$Name,
        [string]$Source,
        [string]$Destination,
        [string]$BackupRelativePath
    )

    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
        throw "Missing source for $Name`: $Source"
    }

    Write-Host "[COPY] $Name -> $Destination"
    if (-not $Apply) {
        return
    }

    if ($BackupRelativePath) {
        Backup-Existing $Destination $BackupRelativePath
    }
    New-Item -ItemType Directory -Path (Split-Path -Parent $Destination) -Force | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

function Copy-OneTree {
    param(
        [string]$Name,
        [string]$Source,
        [string]$Destination,
        [string]$BackupRelativePath
    )

    if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
        throw "Missing source for $Name`: $Source"
    }

    $files = @(Get-ChildItem -LiteralPath $Source -Recurse -Force -File)
    Write-Host "[COPY] $Name ($($files.Count) file(s)) -> $Destination"
    if (-not $Apply) {
        return
    }

    if ($BackupRelativePath) {
        Backup-Existing $Destination $BackupRelativePath
    }
    foreach ($file in $files) {
        $relative = [IO.Path]::GetRelativePath($Source, $file.FullName)
        $target = Join-Path $Destination $relative
        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $target -Force
    }
}

if ($Mode -eq 'Check') {
    $success = $true

    foreach ($mapping in $manifest.Files) {
        if (-not (Test-SameFile $mapping.Name (Join-Path $homeRoot $mapping.Home) (Join-Path $repoRoot $mapping.Repository))) {
            $success = $false
        }
    }
    foreach ($mapping in $manifest.Directories) {
        if (-not (Test-SameTree $mapping.Name (Join-Path $homeRoot $mapping.Home) (Join-Path $repoRoot $mapping.Repository))) {
            $success = $false
        }
    }

    foreach ($installRoot in $manifest.SkillInstallRoots) {
        foreach ($skill in $manifest.Skills) {
            if (-not (Test-SameTree "Skill: $installRoot/$skill" (Get-SkillPath $installRoot $skill) (Join-Path $repoRoot "skills/$skill"))) {
                $success = $false
            }
        }
        foreach ($skill in $removedSkills) {
            if ($null -ne (Get-Item -LiteralPath (Get-SkillPath $installRoot $skill) -Force -ErrorAction SilentlyContinue)) {
                Write-Host "[REMOVE-PENDING] $installRoot/$skill"
                $success = $false
            }
        }
    }

    if (-not $success) {
        exit 1
    }
    exit 0
}

if ($Mode -eq 'Export') {
    foreach ($mapping in $manifest.Files) {
        Copy-OneFile $mapping.Name (Join-Path $homeRoot $mapping.Home) (Join-Path $repoRoot $mapping.Repository)
    }
    foreach ($mapping in $manifest.Directories) {
        Copy-OneTree $mapping.Name (Join-Path $homeRoot $mapping.Home) (Join-Path $repoRoot $mapping.Repository)
    }

    $localSkillRoot = Join-Path $homeRoot $manifest.SkillSourceRoot
    foreach ($skill in $manifest.Skills) {
        Copy-OneTree "Skill: $skill" (Join-Path $localSkillRoot $skill) (Join-Path $repoRoot "skills/$skill")
    }
} else {
    foreach ($mapping in $manifest.Files) {
        Copy-OneFile $mapping.Name (Join-Path $repoRoot $mapping.Repository) (Join-Path $homeRoot $mapping.Home) $mapping.Home
    }
    foreach ($mapping in $manifest.Directories) {
        Copy-OneTree $mapping.Name (Join-Path $repoRoot $mapping.Repository) (Join-Path $homeRoot $mapping.Home) $mapping.Home
    }

    foreach ($installRoot in $manifest.SkillInstallRoots) {
        foreach ($skill in $manifest.Skills) {
            $relativeDestination = "$installRoot/$skill"
            Copy-OneTree "Skill: $skill" (Join-Path $repoRoot "skills/$skill") (Join-Path $homeRoot $relativeDestination) $relativeDestination
        }
        foreach ($skill in $removedSkills) {
            Remove-ManagedSkill $installRoot $skill
        }
    }
}

if (-not $Apply) {
    Write-Host 'Dry run only. Re-run with -Apply to copy files and remove retired skills.'
} elseif ($Mode -eq 'Install' -and (Test-Path -LiteralPath $backupRoot)) {
    Write-Host "Backup: $backupRoot"
}

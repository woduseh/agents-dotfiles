[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$testRoot = Join-Path $repoRoot "work/sync-tests-$([guid]::NewGuid().ToString('N'))"
$fixtureRepo = Join-Path $testRoot 'repo'
$fixtureHome = Join-Path $testRoot 'home'
$pwsh = (Get-Process -Id $PID).Path

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Write-Fixture {
    param([string]$Path, [string]$Content)
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    [IO.File]::WriteAllText($Path, $Content)
}

function Invoke-Sync {
    param([string]$Mode, [bool]$Apply = $false, [string]$HomePath = $fixtureHome, [int]$ExpectedExit = 0)
    $arguments = @('-NoProfile', '-File', (Join-Path $fixtureRepo 'scripts/sync.ps1'), '-Mode', $Mode, '-HomePath', $HomePath)
    if ($Apply) { $arguments += '-Apply' }
    $output = & $pwsh @arguments 2>&1
    Assert-True ($LASTEXITCODE -eq $ExpectedExit) "Unexpected exit $LASTEXITCODE for $Mode`: $output"
}

function Get-Snapshot {
    param([string]$Path)
    @(
        Get-ChildItem -LiteralPath $Path -Recurse -Force -File | Sort-Object FullName | ForEach-Object {
            [IO.Path]::GetRelativePath($Path, $_.FullName) + ':' + (Get-FileHash -LiteralPath $_.FullName).Hash
        }
    ) -join "`n"
}

foreach ($relative in @('manifest.psd1', 'scripts/sync.ps1', 'config/codex/AGENTS.md', 'config/claude/CLAUDE.md')) {
    Write-Fixture (Join-Path $fixtureRepo $relative) (Get-Content -LiteralPath (Join-Path $repoRoot $relative) -Raw)
}
$manifestText = Get-Content -LiteralPath (Join-Path $fixtureRepo 'manifest.psd1') -Raw
$manifest = Import-PowerShellDataFile (Join-Path $fixtureRepo 'manifest.psd1')
foreach ($root in $manifest.SkillInstallRoots) {
    foreach ($skill in $manifest.RemovedSkills) {
        Write-Fixture (Join-Path $fixtureHome "$root/$skill/SKILL.md") "user-edited $root/$skill"
        Write-Fixture (Join-Path $fixtureHome "$root/$skill/references/detail.txt") "nested $root/$skill"
    }
    Write-Fixture (Join-Path $fixtureHome "$root/unmanaged/SKILL.md") 'keep this separate installation'
}
foreach ($skill in $manifest.RemovedSkills) {
    if ($skill -ne 'work-continuity') {
        Write-Fixture (Join-Path $fixtureRepo "skills/$skill/SKILL.md") "archived $skill"
    }
}

$before = Get-Snapshot $fixtureHome
Invoke-Sync Install
Assert-True ((Get-Snapshot $fixtureHome) -eq $before) 'Dry run changed home files'
Assert-True (-not (Test-Path (Join-Path $fixtureHome '.agents-dotfiles-backups'))) 'Dry run created a backup'
Invoke-Sync Check -ExpectedExit 1
Invoke-Sync Install -Apply $true
$backup = @(Get-ChildItem -LiteralPath (Join-Path $fixtureHome '.agents-dotfiles-backups') -Directory)
Assert-True ($backup.Count -eq 1) 'Expected one removal backup'
foreach ($root in $manifest.SkillInstallRoots) {
    foreach ($skill in $manifest.RemovedSkills) {
        Assert-True (-not (Test-Path (Join-Path $fixtureHome "$root/$skill"))) "Skill remains: $root/$skill"
        Assert-True ((Get-Content -Raw (Join-Path $backup[0].FullName "$root/$skill/SKILL.md")) -eq "user-edited $root/$skill") 'Backup lost local edits'
        Assert-True ((Get-Content -Raw (Join-Path $backup[0].FullName "$root/$skill/references/detail.txt")) -eq "nested $root/$skill") 'Backup lost nested content'
    }
    Assert-True ((Get-Content -Raw (Join-Path $fixtureHome "$root/unmanaged/SKILL.md")) -eq 'keep this separate installation') 'Unmanaged skill changed'
}
Invoke-Sync Check
Invoke-Sync Install -Apply $true
Invoke-Sync Check
$sourceBefore = Get-Snapshot (Join-Path $fixtureRepo 'skills')
Invoke-Sync Export -Apply $true
Assert-True ((Get-Snapshot (Join-Path $fixtureRepo 'skills')) -eq $sourceBefore) 'Export changed archived skill sources'
Write-Host '[OK] Preview, pending removals, backup content, unmanaged skills, repeat install, export'

# A retired skill need not retain a source directory; an active skill still copies to both roots.
$activeManifest = $manifestText.Replace('Skills = @()', "Skills = @('sample-skill')")
Write-Fixture (Join-Path $fixtureRepo 'manifest.psd1') $activeManifest
Write-Fixture (Join-Path $fixtureRepo 'skills/sample-skill/SKILL.md') 'active skill'
Invoke-Sync Install -Apply $true
Invoke-Sync Check
Write-Fixture (Join-Path $fixtureHome '.claude/skills/sample-skill/SKILL.md') 'drift'
Invoke-Sync Check -ExpectedExit 1
Invoke-Sync Install -Apply $true
Invoke-Sync Check
Write-Host '[OK] Active installation and drift detection in the Claude destination'

# Rejected paths must not touch an outside directory.
$outside = Join-Path $testRoot 'outside'
Write-Fixture (Join-Path $outside 'creative-writing/SKILL.md') 'outside sentinel'
$outsideBefore = Get-Snapshot $outside
Write-Fixture (Join-Path $fixtureRepo 'manifest.psd1') ($manifestText.Replace("'.agents/skills'", "'../outside'"))
Invoke-Sync Install -Apply $true -ExpectedExit 1
Assert-True ((Get-Snapshot $outside) -eq $outsideBefore) 'Escaping path changed outside files'
Write-Fixture (Join-Path $fixtureRepo 'manifest.psd1') ($manifestText.Replace("'creative-writing'", "'../outside'"))
Invoke-Sync Install -Apply $true -ExpectedExit 1
Assert-True ((Get-Snapshot $outside) -eq $outsideBefore) 'Invalid skill name changed outside files'
Write-Fixture (Join-Path $fixtureRepo 'manifest.psd1') ($manifestText.Replace('Skills = @()', "Skills = @('creative-writing')"))
Invoke-Sync Install -Apply $true -ExpectedExit 1
Write-Host '[OK] Escaping paths, invalid names, and conflicting manifest entries rejected'

Write-Fixture (Join-Path $fixtureRepo 'manifest.psd1') $manifestText
$linkedHome = Join-Path $testRoot 'linked-home'
New-Item -ItemType Directory -Path (Join-Path $linkedHome '.agents/skills') -Force | Out-Null
New-Item -ItemType Junction -Path (Join-Path $linkedHome '.agents/skills/creative-writing') -Target (Join-Path $outside 'creative-writing') | Out-Null
Invoke-Sync Install -Apply $true -HomePath $linkedHome
Assert-True ((Get-Snapshot $outside) -eq $outsideBefore) 'Junction removal changed its target'
Assert-True (-not (Test-Path (Join-Path $linkedHome '.agents/skills/creative-writing'))) 'Junction remains installed'
$linkBackup = Get-ChildItem -LiteralPath (Join-Path $linkedHome '.agents-dotfiles-backups') -Directory | Select-Object -First 1
$savedLink = Get-Item -LiteralPath (Join-Path $linkBackup.FullName '.agents/skills/creative-writing') -Force
Assert-True ($savedLink.LinkType -eq 'Junction') 'Backup did not preserve the junction'
Invoke-Sync Check -HomePath $linkedHome

# Match the real home: Claude links become dangling when Agents folders move first.
$pairedHome = Join-Path $testRoot 'paired-home'
Write-Fixture (Join-Path $pairedHome '.agents/skills/creative-writing/SKILL.md') 'paired source'
New-Item -ItemType Directory -Path (Join-Path $pairedHome '.claude/skills') -Force | Out-Null
New-Item -ItemType Junction -Path (Join-Path $pairedHome '.claude/skills/creative-writing') -Target (Join-Path $pairedHome '.agents/skills/creative-writing') | Out-Null
Invoke-Sync Install -Apply $true -HomePath $pairedHome
Invoke-Sync Check -HomePath $pairedHome
Assert-True ($null -eq (Get-Item -LiteralPath (Join-Path $pairedHome '.claude/skills/creative-writing') -Force -ErrorAction SilentlyContinue)) 'Dangling junction remains'
Write-Host '[OK] Junction backup, target preservation, and paired/dangling links'

$rootLinkedHome = Join-Path $testRoot 'root-linked-home'
New-Item -ItemType Directory -Path (Join-Path $rootLinkedHome '.agents') -Force | Out-Null
New-Item -ItemType Junction -Path (Join-Path $rootLinkedHome '.agents/skills') -Target $outside | Out-Null
Invoke-Sync Install -Apply $true -HomePath $rootLinkedHome -ExpectedExit 1
Assert-True ((Get-Snapshot $outside) -eq $outsideBefore) 'Linked install root changed outside files'
Write-Host '[OK] Linked install root rejected'
Write-Host "Fixtures retained at $testRoot"

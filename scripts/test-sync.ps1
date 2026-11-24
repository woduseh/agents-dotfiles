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
    param([string]$Mode, [bool]$Apply = $false, [string]$HomePath = $fixtureHome, [int]$ExpectedExit = 0, [string]$ExpectedOutput)
    $arguments = @('-NoProfile', '-File', (Join-Path $fixtureRepo 'scripts/sync.ps1'), '-Mode', $Mode, '-HomePath', $HomePath)
    if ($Apply) { $arguments += '-Apply' }
    $output = (& $pwsh @arguments 2>&1 | ForEach-Object { "$_" }) -join "`n"
    Assert-True ($LASTEXITCODE -eq $ExpectedExit) "Unexpected exit $LASTEXITCODE for $Mode`: $output"
    if ($ExpectedOutput) { Assert-True ($output.Contains($ExpectedOutput)) "Expected '$ExpectedOutput' from $Mode`: $output" }
}

function Write-Settings {
    param([string]$HomePath)
    $rules = $manifest.ClaudePermissionRules
    $settings = @{ permissions = @{ allow = @('Bash(npm test *)'); deny = @($rules.Deny); ask = @($rules.Ask) } }
    Write-Fixture (Join-Path $HomePath $manifest.ClaudeSettings) ($settings | ConvertTo-Json -Depth 4)
}

function Get-Snapshot {
    param([string]$Path)
    @(
        Get-ChildItem -LiteralPath $Path -Recurse -Force -File | Sort-Object FullName | ForEach-Object {
            [IO.Path]::GetRelativePath($Path, $_.FullName) + ':' + (Get-FileHash -LiteralPath $_.FullName).Hash
        }
    ) -join "`n"
}

foreach ($relative in @('manifest.psd1', 'scripts/sync.ps1', 'config/codex/AGENTS.md', 'config/claude/CLAUDE.md', 'config/claude/agents/advisor.md', 'config/antigravity/GEMINI.md')) {
    Write-Fixture (Join-Path $fixtureRepo $relative) (Get-Content -LiteralPath (Join-Path $repoRoot $relative) -Raw)
}
$manifestText = Get-Content -LiteralPath (Join-Path $fixtureRepo 'manifest.psd1') -Raw
# Keep the removal fixture independent of the repository's active skill list.
$manifestText = $manifestText -replace '(?m)^    Skills = @\([^)]*\)', '    Skills = @()'
Write-Fixture (Join-Path $fixtureRepo 'manifest.psd1') $manifestText
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
foreach ($path in $manifest.RemovedPaths) {
    Write-Fixture (Join-Path $fixtureHome "$path/old.md") "retired $path"
}
Write-Settings $fixtureHome

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
foreach ($path in $manifest.RemovedPaths) {
    Assert-True (-not (Test-Path (Join-Path $fixtureHome $path))) "Path remains: $path"
    Assert-True ((Get-Content -Raw (Join-Path $backup[0].FullName "$path/old.md")) -eq "retired $path") 'Backup lost a retired path'
}
Invoke-Sync Check
Invoke-Sync Install -Apply $true
Invoke-Sync Check
$sourceBefore = Get-Snapshot (Join-Path $fixtureRepo 'skills')
Invoke-Sync Export -Apply $true
Assert-True ((Get-Snapshot (Join-Path $fixtureRepo 'skills')) -eq $sourceBefore) 'Export changed archived skill sources'
Write-Host '[OK] Preview, pending removals, backup content, unmanaged skills, repeat install, export'

$settingsPath = Join-Path $fixtureHome $manifest.ClaudeSettings
$settingsText = Get-Content -LiteralPath $settingsPath -Raw
$firstDeny = $manifest.ClaudePermissionRules.Deny[0]
Write-Fixture $settingsPath $settingsText.Replace($firstDeny, 'Read(~/elsewhere)')
Invoke-Sync Check -ExpectedExit 1 -ExpectedOutput "[PERMISSION-MISSING] deny: $firstDeny"
Remove-Item -LiteralPath $settingsPath
Invoke-Sync Check -ExpectedExit 1 -ExpectedOutput "[PERMISSION-MISSING] ask: $($manifest.ClaudePermissionRules.Ask[0])"
Write-Fixture $settingsPath $settingsText
Invoke-Sync Check -ExpectedOutput '[SKIP] Git hook'
& git -C $fixtureRepo init --quiet
Invoke-Sync Check -ExpectedExit 1 -ExpectedOutput '[HOOK-MISSING]'
& git -C $fixtureRepo config core.hooksPath hooks
Invoke-Sync Check -ExpectedOutput '[OK] Git hook'
Write-Host '[OK] Missing permission rules, missing settings file, unconnected and connected Git hook'

# A retired skill need not retain a source directory; an active skill still copies to every root.
$activeManifest = $manifestText.Replace('Skills = @()', "Skills = @('sample-skill')")
Write-Fixture (Join-Path $fixtureRepo 'manifest.psd1') $activeManifest
Write-Fixture (Join-Path $fixtureRepo 'skills/sample-skill/SKILL.md') 'active skill'
Invoke-Sync Install -Apply $true
Invoke-Sync Check
Write-Fixture (Join-Path $fixtureHome '.claude/skills/sample-skill/SKILL.md') 'drift'
Invoke-Sync Check -ExpectedExit 1
Invoke-Sync Install -Apply $true
Invoke-Sync Check
Write-Fixture (Join-Path $fixtureHome '.gemini/config/skills/sample-skill/SKILL.md') 'drift'
Invoke-Sync Check -ExpectedExit 1
Invoke-Sync Install -Apply $true
Invoke-Sync Check
Write-Fixture (Join-Path $fixtureHome '.gemini/GEMINI.md') 'drift'
Invoke-Sync Check -ExpectedExit 1
Invoke-Sync Install -Apply $true
Invoke-Sync Check
Write-Host '[OK] Active installation and drift detection in the Claude and Antigravity destinations'

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
Write-Fixture (Join-Path $fixtureRepo 'manifest.psd1') ($manifestText.Replace("'.claude/guides'", "'.claude'"))
Invoke-Sync Install -Apply $true -ExpectedExit 1 -ExpectedOutput 'Path is both managed and removed'
Assert-True (Test-Path -LiteralPath $settingsPath) 'Rejected removal path moved managed files'
Write-Host '[OK] Escaping paths, invalid names, and conflicting manifest entries rejected'

Write-Fixture (Join-Path $fixtureRepo 'manifest.psd1') $manifestText
$linkedHome = Join-Path $testRoot 'linked-home'
New-Item -ItemType Directory -Path (Join-Path $linkedHome '.agents/skills') -Force | Out-Null
New-Item -ItemType Junction -Path (Join-Path $linkedHome '.agents/skills/creative-writing') -Target (Join-Path $outside 'creative-writing') | Out-Null
Write-Settings $linkedHome
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
Write-Settings $pairedHome
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

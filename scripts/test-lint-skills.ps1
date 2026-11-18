#requires -Version 7.0
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$testRoot = Join-Path $repoRoot "work/lint-tests-$([guid]::NewGuid().ToString('N'))"
$pwsh = (Get-Process -Id $PID).Path
$bash = 'bash'
if ($IsWindows) {
    # A bare `bash` on Windows can resolve to the WSL launcher, which cannot read these paths.
    $folder = Split-Path -Parent (Get-Command git -CommandType Application | Select-Object -First 1).Source
    while ($folder -and -not (Test-Path -LiteralPath (Join-Path $folder 'bin/bash.exe') -PathType Leaf)) {
        $folder = Split-Path -Parent $folder
    }
    if (-not $folder) { throw 'Git Bash not found above the git executable.' }
    $bash = Join-Path $folder 'bin/bash.exe'
}

function Write-Fixture {
    param([string]$Path, [string]$Content)
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    [IO.File]::WriteAllText($Path, $Content)
}

function Write-Skill {
    param(
        [string]$Root,
        [string]$Directory,
        [string[]]$Frontmatter = @("name: $Directory", 'description: Does one thing.'),
        [string]$Body = "# Body`n",
        [bool]$WithOpenAi = $true
    )
    Write-Fixture (Join-Path $Root "skills/$Directory/SKILL.md") ("---`n" + ($Frontmatter -join "`n") + "`n---`n" + $Body)
    if ($WithOpenAi) { Write-Fixture (Join-Path $Root "skills/$Directory/agents/openai.yaml") "interface: {}`n" }
}

function Assert-BothLints {
    param([string]$Root, [string[]]$Expected)
    $expectedExit = if ($Expected -match '^\[FAIL\]') { 1 } else { 0 }
    [Array]::Sort($Expected, [StringComparer]::Ordinal)
    $lints = @(
        @{ Name = 'lint-skills.ps1'; Command = $pwsh; Arguments = @('-NoProfile', '-File', (Join-Path $PSScriptRoot 'lint-skills.ps1'), '-RepoRoot', $Root) }
        @{ Name = 'lint-skills.sh'; Command = $bash; Arguments = @((Join-Path $PSScriptRoot 'lint-skills.sh').Replace('\', '/'), $Root.Replace('\', '/')) }
    )
    foreach ($lint in $lints) {
        $arguments = $lint.Arguments
        [string[]]$lines = @(& $lint.Command @arguments 2>&1 | ForEach-Object { "$_" })
        $exit = $LASTEXITCODE
        [Array]::Sort($lines, [StringComparer]::Ordinal)
        $difference = @(Compare-Object -ReferenceObject $Expected -DifferenceObject $lines -CaseSensitive | ForEach-Object { "$($_.SideIndicator) $($_.InputObject)" })
        if ($difference.Count -gt 0) {
            throw "$($lint.Name) differs from the expected output (<= expected only, => actual only):`n$($difference -join "`n")"
        }
        if ($exit -ne $expectedExit) { throw "$($lint.Name) exited $exit, expected $expectedExit" }
    }
}

$clean = Join-Path $testRoot 'clean'
Write-Fixture (Join-Path $clean 'manifest.psd1') "@{`n    Skills = @('good-skill')`n    RemovedSkills = @(`n        'old-skill'`n    )`n}`n"
Write-Skill $clean 'good-skill' -Frontmatter @('name: good-skill', "description: `"$('가' * 1024)`"") -Body "# Body`n`nSee [detail](references/detail.md).`n"
Write-Fixture (Join-Path $clean 'skills/good-skill/references/detail.md') "# Detail`n"
Write-Fixture (Join-Path $clean 'evals/routing-cases.json') "{`"cases`": [`n  {`"query`": `"q`", `"expect`": `"good-skill`", `"exclude`": []},`n  {`"query`": `"q`", `"expect`": null, `"exclude`": [`"good-skill`"]}`n]}`n"
Assert-BothLints $clean @('[OK] 1 skills passed')
Write-Host '[OK] Clean fixture: both lints pass, including a 1024-character multibyte description'

$broken = Join-Path $testRoot 'broken'
$listed = @(
    'good-skill', 'no-skill-file', 'no-frontmatter', 'wrong-name', 'claude-helper', 'Upper_Case', 'no-name', 'no-description',
    'empty-description', 'tagged-description', 'long-description', 'long-file', 'broken-link', 'no-openai', 'ghost-skill', 'twice-listed'
)
Write-Fixture (Join-Path $broken 'manifest.psd1') "@{`n    Skills = @($(($listed | ForEach-Object { "'$_'" }) -join ', '))`n    RemovedSkills = @(`n        'twice-listed'`n        'Bad_Name'`n    )`n}`n"
Write-Skill $broken 'good-skill'
Write-Fixture (Join-Path $broken 'skills/no-skill-file/agents/openai.yaml') "interface: {}`n"
Write-Fixture (Join-Path $broken 'skills/no-frontmatter/SKILL.md') "# No frontmatter`n"
Write-Fixture (Join-Path $broken 'skills/no-frontmatter/agents/openai.yaml') "interface: {}`n"
Write-Skill $broken 'wrong-name' -Frontmatter @('name: other-name', 'description: Does one thing.')
Write-Skill $broken 'claude-helper'
Write-Skill $broken 'Upper_Case'
Write-Skill $broken 'no-name' -Frontmatter @('description: Does one thing.')
Write-Skill $broken 'no-description' -Frontmatter @('name: no-description')
Write-Skill $broken 'empty-description' -Frontmatter @('name: empty-description', 'description: ""')
Write-Skill $broken 'tagged-description' -Frontmatter @('name: tagged-description', 'description: Uses <b>tags</b> in text.')
Write-Skill $broken 'long-description' -Frontmatter @('name: long-description', "description: `"$('가' * 1025)`"")
Write-Skill $broken 'long-file' -Body ((1..497 | ForEach-Object { "line $_" }) -join "`n")
Write-Skill $broken 'broken-link' -Body "See [missing](references/missing.md).`n"
Write-Skill $broken 'no-openai' -WithOpenAi $false
Write-Skill $broken 'unlisted-skill'
Write-Fixture (Join-Path $broken 'evals/routing-cases.json') "{`"cases`": [`n  {`"query`": `"q`", `"expect`": `"retired-skill`", `"exclude`": [`"good-skill`", `"typo-skill`"]}`n]}`n"
Assert-BothLints $broken @(
    '[FAIL] no-skill-file: missing SKILL.md'
    '[FAIL] no-frontmatter: no YAML frontmatter'
    "[FAIL] wrong-name: name 'other-name' does not match directory"
    '[FAIL] claude-helper: name contains a reserved word'
    '[FAIL] Upper_Case: name must be 1-64 lowercase letters, digits, or hyphens'
    '[FAIL] no-name: missing name'
    '[FAIL] no-description: missing description'
    '[FAIL] empty-description: empty description'
    '[FAIL] tagged-description: description contains XML tags'
    '[FAIL] long-description: description longer than 1024 characters'
    '[FAIL] long-file: SKILL.md has 501 lines (limit 500)'
    "[FAIL] broken-link: broken link 'references/missing.md' in SKILL.md"
    '[FAIL] no-openai: missing agents/openai.yaml'
    '[FAIL] unlisted-skill: not listed in manifest.psd1'
    "[FAIL] manifest lists 'ghost-skill' but skills/ghost-skill does not exist"
    "[FAIL] manifest lists 'twice-listed' but skills/twice-listed does not exist"
    '[FAIL] Invalid removed skill name: Bad_Name'
    '[FAIL] Skill is both installed and removed: twice-listed'
    "[FAIL] evals/routing-cases.json: unknown skill 'retired-skill'"
    "[FAIL] evals/routing-cases.json: unknown skill 'typo-skill'"
)
Write-Host '[OK] Broken fixture: both lints report the same 20 failures'

$noRouting = Join-Path $testRoot 'no-routing'
Write-Fixture (Join-Path $noRouting 'manifest.psd1') "@{`n    Skills = @('good-skill')`n    RemovedSkills = @()`n}`n"
Write-Skill $noRouting 'good-skill'
Assert-BothLints $noRouting @('[FAIL] evals/routing-cases.json not found')
Write-Host '[OK] Missing routing seeds reported by both lints'
Write-Host "Fixtures retained at $testRoot"

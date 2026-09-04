[CmdletBinding()]
param(
    [string]$RepoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Static checks for skills/*/SKILL.md: frontmatter, sizes, reference links, and manifest coverage.
$manifest = Import-PowerShellDataFile -LiteralPath (Join-Path $RepoRoot 'manifest.psd1')
$skillsRoot = Join-Path $RepoRoot 'skills'
$problems = New-Object System.Collections.Generic.List[string]

$skillDirs = @(Get-ChildItem -LiteralPath $skillsRoot -Directory | Sort-Object Name)
foreach ($dir in $skillDirs) {
    $skillFile = Join-Path $dir.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
        $problems.Add("$($dir.Name): missing SKILL.md")
        continue
    }

    $text = Get-Content -LiteralPath $skillFile -Raw
    if ($text -notmatch '(?s)\A---\r?\n(.*?)\r?\n---\r?\n') {
        $problems.Add("$($dir.Name): no YAML frontmatter")
        continue
    }
    $frontmatter = $Matches[1]

    if ($frontmatter -match '(?m)^name:\s*"?([^"\r\n]*)"?\s*$') {
        $name = $Matches[1].Trim()
        if ($name -ne $dir.Name) { $problems.Add("$($dir.Name): name '$name' does not match directory") }
        if ($name -notmatch '^[a-z0-9-]{1,64}$') { $problems.Add("$($dir.Name): name must be 1-64 lowercase letters, digits, or hyphens") }
        if ($name -match 'anthropic|claude') { $problems.Add("$($dir.Name): name contains a reserved word") }
    } else {
        $problems.Add("$($dir.Name): missing name")
    }

    if ($frontmatter -match '(?m)^description:\s*"?(.*?)"?\s*$') {
        $description = $Matches[1].Trim()
        if ($description.Length -eq 0) { $problems.Add("$($dir.Name): empty description") }
        if ($description.Length -gt 1024) { $problems.Add("$($dir.Name): description longer than 1024 characters") }
        if ($description -match '<[^>]+>') { $problems.Add("$($dir.Name): description contains XML tags") }
    } else {
        $problems.Add("$($dir.Name): missing description")
    }

    $lineCount = ($text -split "`n").Count
    if ($lineCount -gt 500) { $problems.Add("$($dir.Name): SKILL.md has $lineCount lines (limit 500)") }

    $markdownFiles = @(Get-Item -LiteralPath $skillFile) + @(Get-ChildItem -LiteralPath $dir.FullName -Recurse -File -Filter '*.md' | Where-Object { $_.FullName -ne $skillFile })
    foreach ($file in $markdownFiles) {
        $content = Get-Content -LiteralPath $file.FullName -Raw
        foreach ($match in [regex]::Matches($content, '\]\(([^)]+\.md)\)')) {
            $target = Join-Path $file.DirectoryName $match.Groups[1].Value
            if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
                $problems.Add("$($dir.Name): broken link '$($match.Groups[1].Value)' in $($file.Name)")
            }
        }
    }

    if (-not (Test-Path -LiteralPath (Join-Path $dir.FullName 'agents/openai.yaml') -PathType Leaf)) {
        $problems.Add("$($dir.Name): missing agents/openai.yaml")
    }

    if ($manifest.Skills -notcontains $dir.Name -and $manifest.RemovedSkills -notcontains $dir.Name) {
        $problems.Add("$($dir.Name): not listed in manifest.psd1")
    }
}

foreach ($listed in $manifest.Skills) {
    if (-not (Test-Path -LiteralPath (Join-Path $skillsRoot $listed) -PathType Container)) {
        $problems.Add("manifest lists '$listed' but skills/$listed does not exist")
    }
}

foreach ($listed in $manifest.RemovedSkills) {
    if ($listed -notmatch '^[a-z0-9-]{1,64}$') { $problems.Add("Invalid removed skill name: $listed") }
    if ($manifest.Skills -contains $listed) { $problems.Add("Skill is both installed and removed: $listed") }
}

if ($problems.Count -gt 0) {
    $problems | ForEach-Object { Write-Host "[FAIL] $_" }
    exit 1
}

Write-Host "[OK] $($skillDirs.Count) skills passed"
exit 0

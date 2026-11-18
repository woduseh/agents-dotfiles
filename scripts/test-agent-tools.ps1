#requires -Version 7.0
[CmdletBinding()]
param([string[]]$NodeVersions = @('24.21.0', '26.10.0'))

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$repoRoot = Split-Path -Parent $PSScriptRoot
$testRoot = Join-Path $repoRoot "work/agent-tools-tests-$([guid]::NewGuid().ToString('N'))"
$pwsh = (Get-Process -Id $PID).Path
$runner = Join-Path $PSScriptRoot 'repo-run.ps1'
$doctor = Join-Path $PSScriptRoot 'agent-doctor.ps1'
$originalPath = $env:Path
$originalLocation = (Get-Location).Path

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}
function Invoke-TestScript {
    param([string]$Script, [string[]]$Arguments, [int]$ExpectedExit = 0)
    $output = @(& $pwsh -NoProfile -File $Script @Arguments 2>&1)
    Assert-True ($LASTEXITCODE -eq $ExpectedExit) "Expected exit $ExpectedExit, got $LASTEXITCODE`: $output"
    ($output | ForEach-Object { "$_" }) -join "`n"
}

New-Item -ItemType Directory -Path $testRoot -Force | Out-Null
foreach ($version in $NodeVersions) {
    $project = Join-Path $testRoot "한글 project $version"
    New-Item -ItemType Directory -Path $project | Out-Null
    $pinName = if ($version -eq $NodeVersions[0]) { '.nvmrc' } else { '.node-version' }
    [IO.File]::WriteAllText((Join-Path $project $pinName), $version)
    $probe = Join-Path $project 'argument probe.cjs'
    [IO.File]::WriteAllText($probe, 'console.log(JSON.stringify({version:process.versions.node,cwd:process.cwd(),args:process.argv.slice(2)}))')
    $expectedArguments = @('한글 공백', 'quote"inside', 'literal$(not-executed)', 'a&b', '--debug', '-Verbose', '-Command', '-ProjectPath', '')
    $output = Invoke-TestScript $runner (@($project, 'node', $probe) + $expectedArguments)
    $result = $output | ConvertFrom-Json
    Assert-True ($result.version -eq $version) 'Wrong Node version selected.'
    Assert-True ($result.cwd -eq $project) 'Wrong project working directory.'
    Assert-True (($result.args | ConvertTo-Json -Compress) -eq ($expectedArguments | ConvertTo-Json -Compress)) "Arguments changed: $output"
    $npm = Invoke-TestScript $runner @($project, 'npm', '--version')
    Assert-True ($npm.Trim() -match '^\d+\.\d+\.\d+$') "npm launcher failed: $npm"
    [IO.File]::WriteAllText((Join-Path $project 'package.json'), '{"private":true,"scripts":{"probe":"node \"argument probe.cjs\""}}')
    $npmResult = (Invoke-TestScript $runner @($project, 'npm', 'run', '--silent', 'probe', '--', 'npm 한글 argument', '--flag')) | ConvertFrom-Json
    Assert-True ($npmResult.version -eq $version -and $npmResult.cwd -eq $project) 'npm script used the wrong Node or cwd.'
    Assert-True (($npmResult.args | ConvertTo-Json -Compress) -eq '["npm 한글 argument","--flag"]') 'npm script arguments changed.'
    $failure = Join-Path $project 'failure.cjs'
    [IO.File]::WriteAllText($failure, 'console.log("stdout-sentinel");console.error("stderr-sentinel");process.exit(17)')
    $output = Invoke-TestScript $runner @($project, 'node', $failure) 17
    Assert-True ($output.Contains('stdout-sentinel') -and $output.Contains('stderr-sentinel')) 'Lost child output.'
    $report = (Invoke-TestScript $doctor @('-ProjectPath', $project, '-Json')) | ConvertFrom-Json
    Assert-True ($report.Ready -and $report.RequiredNode -eq $version) 'Doctor did not report project readiness.'
    Assert-True (($report.Checks | Where-Object Name -eq 'project-node').Status -eq 'OK') 'Managed Node probe failed.'
    Write-Host "[OK] Node $version, cwd, Unicode/quoted/literal/empty arguments, npm, stdout/stderr, exit 17, doctor JSON"
}

$invalidProject = Join-Path $testRoot 'invalid-project'
New-Item -ItemType Directory -Path $invalidProject | Out-Null
$null = Invoke-TestScript $runner @($invalidProject, 'node', '--version') 2
$noPin = (Invoke-TestScript $doctor @('-ProjectPath', $invalidProject, '-Json')) | ConvertFrom-Json
Assert-True (($noPin.Checks | Where-Object Name -eq 'project-node').Status -eq 'WARN') 'Missing pin must be visible.'
[IO.File]::WriteAllText((Join-Path $invalidProject '.nvmrc'), '0.0.0')
$missing = (Invoke-TestScript $doctor @('-ProjectPath', $invalidProject, '-Json') 1) | ConvertFrom-Json
Assert-True (-not $missing.Ready) 'An unavailable Node version must not report ready.'
$sentinel = Join-Path $invalidProject 'must-not-run.cjs'
[IO.File]::WriteAllText($sentinel, 'require("fs").writeFileSync("unexpected.txt","ran")')
$null = Invoke-TestScript $runner @($invalidProject, 'node', $sentinel) 1
Assert-True (-not (Test-Path -LiteralPath (Join-Path $invalidProject 'unexpected.txt'))) 'Ran with a fallback Node version.'
[IO.File]::WriteAllText((Join-Path $invalidProject '.node-version'), $NodeVersions[0])
$null = Invoke-TestScript $runner @($invalidProject, 'node', $sentinel) 2
$bad = (Invoke-TestScript $doctor @('-ProjectPath', $invalidProject, '-Json') 2) | ConvertFrom-Json
Assert-True ($bad.Error -match 'Conflicting') 'Conflicting version files were not diagnosed.'
Assert-True ($env:Path -eq $originalPath -and (Get-Location).Path -eq $originalLocation) 'Parent environment changed.'
Write-Host '[OK] Missing/unavailable/conflicting pins, no fallback execution, parent PATH/cwd preserved'
Write-Host "Fixtures: $testRoot"

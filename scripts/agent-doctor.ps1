#requires -Version 7.0
<#
.SYNOPSIS
Report tool paths, versions and project Node readiness. Does not install anything.
.EXAMPLE
agent-doctor.ps1 -ProjectPath C:\src\my-project -Json
.NOTES
Exit 0: ready (possibly with warnings). Exit 1: required tool or Node check failed.
Exit 2: invalid project configuration. Optional diagnostic tools do not block work.
#>
[CmdletBinding()]
param([string]$ProjectPath = '.', [switch]$Json)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$originalPath = $env:Path
$checks = [Collections.Generic.List[object]]::new()
function Add-Check {
    param([string]$Name, [string]$Status, [string]$Path, [string]$Detail)
    $checks.Add([pscustomobject]@{ Name = $Name; Status = $Status; Path = $Path; Detail = $Detail })
}
function Get-ToolProbe {
    param([string]$Executable, [string[]]$Arguments)
    try {
        $output = @(& $Executable @Arguments 2>&1)
        [pscustomobject]@{ ExitCode = $LASTEXITCODE; Text = ($output | ForEach-Object { "$_" }) -join "`n" }
    } catch {
        [pscustomobject]@{ ExitCode = -1; Text = $_.Exception.Message }
    }
}

$exitCode = 2
try {
    . (Join-Path $PSScriptRoot 'agent-tools-common.ps1')
    $project = Get-AgentProject $ProjectPath
    Add-AgentUserPath
    $resolved = @{}
    foreach ($name in @('git', 'gh', 'fnm', 'uv', 'jq', 'node', 'python', 'handle', 'es')) {
        $tool = Get-Command $name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $tool) {
            $status = if ($name -in @('git', 'fnm', 'uv', 'jq')) { 'FAIL' } else { 'WARN' }
            Add-Check $name $status '' 'Not found on PATH.'
            continue
        }
        $resolved[$name] = $tool.Source
        if ($name -in @('handle', 'python')) {
            # Do not launch a WindowsApps alias or request administrator rights.
            $detail = if ($name -eq 'handle') { 'Installed; inspecting handles requires administrator rights.' } else { 'PATH candidate only; managed Python is checked separately.' }
            Add-Check $name 'INFO' $tool.Source $detail
            continue
        }
        $flags = if ($name -eq 'es') { @('-version') } else { @('--version') }
        $probe = Get-ToolProbe $tool.Source $flags
        $status = if ($probe.ExitCode -eq 0) { 'OK' } elseif ($name -in @('git','fnm','uv','jq')) { 'FAIL' } else { 'WARN' }
        if ($name -eq 'node' -and $status -eq 'OK' -and $project.NodeVersion -and
            $probe.Text.Trim() -ne "v$($project.NodeVersion)") {
            $status = 'WARN'
            $probe.Text += " (PATH differs from project Node $($project.NodeVersion); use repo-run.)"
        }
        Add-Check $name $status $tool.Source ($probe.Text -split "`r?`n")[0]
    }
    if ($project.NodeVersion -and $resolved.ContainsKey('fnm')) {
        $probe = Get-ToolProbe $resolved.fnm @('exec', '--using', $project.NodeVersion, '--', 'node', '-p', 'process.versions.node')
        $status = if ($probe.ExitCode -eq 0 -and $probe.Text.Trim() -eq $project.NodeVersion) { 'OK' } else { 'FAIL' }
        $detail = if ($status -eq 'OK') { "Node $($project.NodeVersion) is ready for repo-run." } else { "Required Node $($project.NodeVersion) unavailable. Install with: fnm install $($project.NodeVersion). $($probe.Text)" }
        Add-Check 'project-node' $status $resolved.fnm $detail
    } elseif (-not $project.NodeVersion) {
        Add-Check 'project-node' 'WARN' $project.Path 'No exact Node version file; repo-run requires one.'
    }
    if ($resolved.ContainsKey('uv')) {
        $probe = Get-ToolProbe $resolved.uv @('python', 'find', '--managed-python', '--offline')
        if ($probe.ExitCode -eq 0) {
            $pythonPath = $probe.Text.Trim()
            $pythonProbe = Get-ToolProbe $pythonPath @('--version')
            $status = if ($pythonProbe.ExitCode -eq 0) { 'OK' } else { 'FAIL' }
            Add-Check 'managed-python' $status $pythonPath $pythonProbe.Text
        } else {
            Add-Check 'managed-python' 'WARN' '' 'No matching uv-managed Python found offline.'
        }
    }
    $exitCode = if (@($checks | Where-Object Status -eq 'FAIL').Count) { 1 } else { 0 }
    $report = [pscustomobject]@{ Project = $project.Path; RequiredNode = $project.NodeVersion; Ready = ($exitCode -eq 0); Checks = @($checks.ToArray()) }
    if ($Json) { $report | ConvertTo-Json -Depth 5 } else {
        "Project: $($project.Path)"
        "Required Node: $($project.NodeVersion)"
        $checks | Format-Table Name, Status, Detail, Path -Wrap
    }
} catch {
    if ($Json) { [pscustomobject]@{ Ready = $false; Error = $_.Exception.Message } | ConvertTo-Json } else { [Console]::Error.WriteLine("agent-doctor: $($_.Exception.Message)") }
} finally {
    $env:Path = $originalPath
}
exit $exitCode

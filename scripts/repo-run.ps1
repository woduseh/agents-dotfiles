#requires -Version 7.0
<#
.SYNOPSIS
Run an executable using the project's exact Node version, without a shell profile.
.EXAMPLE
repo-run.ps1 C:\src\my-project npm run check
.NOTES
Requires a .node-version or .nvmrc and an already installed fnm Node version.
All remaining arguments are passed as arguments, never evaluated as shell code.
Use pwsh -File to run this script from another script and retain its exit code.
#>
# No named parameters: even child flags named -Command or -ProjectPath stay literal.
$invocationArguments = $args
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$exitCode = 2
$originalPath = $env:Path
$locationPushed = $false
try {
    . (Join-Path $PSScriptRoot 'agent-tools-common.ps1')
    if ($invocationArguments.Count -lt 2) { throw 'Usage: repo-run.ps1 <project-directory> <executable> [arguments...]' }
    $ProjectPath = [string]$invocationArguments[0]
    $Command = [string]$invocationArguments[1]
    [string[]]$commandArguments = if ($invocationArguments.Count -gt 2) { $invocationArguments[2..($invocationArguments.Count - 1)] } else { @() }
    if ([string]::IsNullOrWhiteSpace($Command)) { throw 'Specify -Command followed by an executable and its arguments.' }
    Add-AgentUserPath
    $project = Get-AgentProject $ProjectPath
    if (-not $project.NodeVersion) { throw 'ProjectPath must contain a .node-version or .nvmrc with an exact Node version.' }
    $fnm = (Get-Command fnm -CommandType Application -ErrorAction Stop).Source
    # fnm does not expand PATHEXT; Node ships these two launchers as .cmd files.
    if ($IsWindows -and $Command -in @('npm', 'npx')) { $Command += '.cmd' }
    Push-Location -LiteralPath $project.Path
    $locationPushed = $true
    & $fnm exec --using $project.NodeVersion -- $Command @commandArguments
    $exitCode = $LASTEXITCODE
} catch {
    [Console]::Error.WriteLine("repo-run: $($_.Exception.Message)")
} finally {
    if ($locationPushed) { Pop-Location }
    $env:Path = $originalPath
}
exit $exitCode

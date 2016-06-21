#requires -Version 2 -Modules posh-git

. "$PSScriptRoot\Themes\Avit.ps1"

<#
        .SYNOPSIS
        Method called at each launch of Powershell

        .DESCRIPTION
        Sets up things needed in each console session, aside from prompt
#>
function Start-Up
{
    if(Test-Path -Path ~\.last)
    {
        (Get-Content -Path ~\.last) | Set-Location
        Remove-Item -Path ~\.last
    }

    # Makes git diff work
    $env:TERM = 'msys'

    if(Get-Module -Name Posh-Git)
    {
        Start-SshAgent -Quiet
    }
}

<#
        .SYNOPSIS
        Generates the prompt before each line in the console
#>
function Prompt
{
    $lastCommandFailed = !$?

    #Start the vanilla posh-git when in a vanilla window, else: go nuts
    if(Test-IsVanillaWindow)
    {
        Write-Host -Object ($pwd.ProviderPath) -NoNewline
        Write-VcsStatus
        $global:LASTEXITCODE = !$lastCommandFailed
        return '> '
    }

    Write-Theme

    return ' '
}

Start-Up # Executes the Start-Up function, better encapsulation
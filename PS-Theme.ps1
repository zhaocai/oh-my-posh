#requires -Version 2 -Modules posh-git

. "$PSScriptRoot\Themes\Tools.ps1"

$global:ThemeSettings = New-Object -TypeName PSObject -Property @{
    Theme                            = 'Agnoster'
    GitBranchSymbol                  = [char]::ConvertFromUtf32(0xE0A0)
    FailedCommandSymbol              = [char]::ConvertFromUtf32(0x2716)
    TruncatedFolderSymbol            = '..'
    BeforeStashSymbol                = '{'
    AfterStashSymbol                 = '}'
    DelimSymbol                      = '|'
    LocalWorkingStatusSymbol         = '!'
    LocalStagedStatusSymbol          = '~'
    LocalDefaultStatusSymbol         = ''
    BranchUntrackedSymbol            = [char]::ConvertFromUtf32(0x2262)
    BranchIdenticalStatusToSymbol    = [char]::ConvertFromUtf32(0x2263)
    BranchAheadStatusSymbol          = [char]::ConvertFromUtf32(0x2191)
    BranchBehindStatusSymbol         = [char]::ConvertFromUtf32(0x2193)
    ElevatedSymbol                   = [char]::ConvertFromUtf32(0x26A1)
    GitDefaultColor                  = [ConsoleColor]::DarkCyan
    GitLocalChangesColor             = [ConsoleColor]::DarkGreen
    GitNoLocalChangesAndAheadColor   = [ConsoleColor]::DarkGray
    PromptForegroundColor            = [ConsoleColor]::Black
    PromptBackgroundColor            = [ConsoleColor]::DarkBlue
    SessionInfoBackgroundColor       = [ConsoleColor]::Green
    CommandFailedIconForegroundColor = [ConsoleColor]::Red
    AdminIconForegroundColor         = [ConsoleColor]::DarkGreen
}

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

    # check if the theme exists
    if (!(Test-Path "$PSScriptRoot\Themes\$($global:ThemeSettings.Theme).ps1"))
    {
        # fall back to Agnoster if not found
        $global:ThemeSettings.Theme = 'Agnoster'
    }
    
    . "$PSScriptRoot\Themes\$($global:ThemeSettings.Theme).ps1"

    Write-Theme

    return ' '
}

Start-Up # Executes the Start-Up function, better encapsulation
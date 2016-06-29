Import-Module -Name posh-git -ErrorAction SilentlyContinue
Import-Module -Name PSColor -ErrorAction SilentlyContinue
Import-Module -Name Find-String -ErrorAction SilentlyContinue
Import-Module -Name Invoke-ElevatedCommand -ErrorAction SilentlyContinue
Import-Module -Name z -ErrorAction SilentlyContinue
Import-Module -Name out-diff -ErrorAction SilentlyContinue
Import-Module -Name PoShAncestry -ErrorAction SilentlyContinue
Import-Module -Name PoShWarp -ErrorAction SilentlyContinue
Import-Module -Name PsUrl -ErrorAction SilentlyContinue

#requires -Version 2 -Modules posh-git

. "$PSScriptRoot\Themes\Tools.ps1"
. "$PSScriptRoot\defaults.ps1"

$global:ThemeSettings = New-Object -TypeName PSObject -Property @{
    Theme                            = 'Agnoster'
    GitBranchSymbol                  = [char]::ConvertFromUtf32(0xE0A0)
    FailedCommandSymbol              = [char]::ConvertFromUtf32(0x2A2F)
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
    GitNoLocalChangesAndAheadColor   = [ConsoleColor]::DarkMagenta
    PromptForegroundColor            = [ConsoleColor]::Cyan
    DriveForegroundColor             = [ConsoleColor]::DarkBlue
    PromptBackgroundColor            = [ConsoleColor]::DarkBlue
    PromptSymbolColor                = [ConsoleColor]::Red
    SessionInfoBackgroundColor       = [ConsoleColor]::Green
    CommandFailedIconForegroundColor = [ConsoleColor]::DarkYellow
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

    # Set sane defaults
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
}

<#
        .SYNOPSIS
        Generates the prompt before each line in the console
#>
function global:prompt
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
    if (!(Test-Path "$PSScriptRoot\Themes\$($sl.Theme).ps1"))
    {
        # fall back to Agnoster if not found
        $sl.Theme = 'Agnoster'
    }

    . "$PSScriptRoot\Themes\$($sl.Theme).ps1"

    Write-Theme

    return ' '
}

function Show-ThemeColors
{
    Write-Host -Object ''
    Write-ColorPreview -text 'GitDefaultColor                  ' -color $sl.GitDefaultColor
    Write-ColorPreview -text 'GitLocalChangesColor             ' -color $sl.GitLocalChangesColor
    Write-ColorPreview -text 'GitNoLocalChangesAndAheadColor   ' -color $sl.GitNoLocalChangesAndAheadColor
    Write-ColorPreview -text 'PromptForegroundColor            ' -color $sl.PromptForegroundColor
    Write-ColorPreview -text 'PromptBackgroundColor            ' -color $sl.PromptBackgroundColor
    Write-ColorPreview -text 'PromptSymbolColor                ' -color $sl.PromptSymbolColor
    Write-ColorPreview -text 'SessionInfoBackgroundColor       ' -color $sl.SessionInfoBackgroundColor
    Write-ColorPreview -text 'CommandFailedIconForegroundColor ' -color $sl.CommandFailedIconForegroundColor
    Write-ColorPreview -text 'AdminIconForegroundColor         ' -color $sl.AdminIconForegroundColor
    Write-Host -Object ''
}

function Write-ColorPreview
{
    param
    (
        [string]
        $text,
        [ConsoleColor]
        $color
    )

    Write-Host -Object $text -NoNewline
    Write-Host -Object '       ' -BackgroundColor $color
}

function Show-Colors
{
    for($i = 1; $i -lt 16; $i++)
    {
        $color = [ConsoleColor]$i
        Write-Host -Object $color -BackgroundColor $i
    }
}

function Show-Themes
{
    Write-Host ''
    Write-Host 'Themes:'
    Write-Host ''
    Get-ChildItem -Path "$PSScriptRoot\Themes\*" -Include '*.ps1' -Exclude Tools.ps1 | Sort-Object Name | ForEach-Object -Process {write-Host "- $($_.BaseName)"} 
    Write-Host ''
    
}

Start-Up # Executes the Start-Up function, better encapsulation
$sl = $global:ThemeSettings #local settings
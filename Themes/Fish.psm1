#requires -Version 2 -Modules posh-git

. "$PSScriptRoot\Tools.ps1"

function Write-Theme
{
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )
    
    $fancySpacerSymbol = [char]::ConvertFromUtf32(0xE0B0)
    $betweenFancySpacerSymbol = [char]::ConvertFromUtf32(0xE0B1)

    $prompt = ' '
    Write-Prompt -Object $prompt -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor

    #check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
    {
        $prompt = $prompt + "$($sl.ElevatedSymbol) "
        Write-Prompt -Object "$($sl.ElevatedSymbol) " -ForegroundColor $sl.AdminIconForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    }

    $user = [Environment]::UserName
    $computer = $env:computername
    $path = (Get-Location).Path.Replace($HOME,'~')
    
    $prompt = $prompt + "$user@$computer $fancySpacerSymbol $path "
    Write-Prompt -Object "$user@$computer " -ForegroundColor $sl.SessionInfoForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    Write-Prompt -Object "$fancySpacerSymbol " -ForegroundColor $sl.SessionInfoBackgroundColor -BackgroundColor $sl.PromptBackgroundColor

    # Writes the drive portion
    Write-Prompt -Object "$path " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor

    $status = Get-VCSStatus
    if ($status)
    {
        $themeInfo = Get-VcsInfo -status ($status)
        $prompt = $prompt + $betweenFancySpacerSymbol + " $($themeInfo.VcInfo) "
        Write-Prompt -Object $betweenFancySpacerSymbol -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor
        Write-Prompt -Object " $($themeInfo.VcInfo) " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor 
    }

    # Writes the postfix to the prompt
    $prompt = $prompt + $fancySpacerSymbol
    Write-Prompt -Object $fancySpacerSymbol -ForegroundColor $sl.PromptBackgroundColor -BackgroundColor $sl.PromptHighlightColor 

    $backwardSpacerSymbol = [char]::ConvertFromUtf32(0xE0B2)
    $betweenBackwardSpacerSymbol = [char]::ConvertFromUtf32(0xE0B3)
    $date = Get-Date -UFormat %d-%m-%Y
    $timeStamp = Get-Date -UFormat %R
    $leftText = "$backwardSpacerSymbol $date $betweenBackwardSpacerSymbol $timeStamp "

    $remainingWidth = Get-BetweenSpace -promptText $prompt -endText $leftText

    Write-Prompt -Object $backwardSpacerSymbol.PadLeft($remainingWidth - $leftText.length, ' ') -ForegroundColor $sl.PromptBackgroundColor -BackgroundColor $sl.PromptHighlightColor 
    
    Write-Host " $date $betweenBackwardSpacerSymbol $timeStamp " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor 
    
    $foregroundColor = $sl.PromptSymbolColor
    If ($lastCommandFailed)
    {
        $foregroundColor = $sl.CommandFailedIconForegroundColor
    }

    if ($with)
    {
        Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.WithBackgroundColor -ForegroundColor $sl.WithForegroundColor
    }

    $promptSymbol = [char]::ConvertFromUtf32(0x25B6)
    Write-Prompt -Object $promptSymbol -ForegroundColor $foregroundColor
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbolColor = [ConsoleColor]::White
$sl.PromptForegroundColor = [ConsoleColor]::White
$sl.PromptHighlightColor = [ConsoleColor]::Magenta
$sl.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.WithBackgroundColor = [ConsoleColor]::Magenta

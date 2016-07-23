#requires -Version 2 -Modules posh-git

. "$PSScriptRoot\Tools.ps1"

function Write-Theme
{
    param(
        [bool]
        $lastCommandFailed
    )
    
    $fancySpacerSymbol = [char]::ConvertFromUtf32(0xE0B0)
    $betweenFancySpacerSymbol = [char]::ConvertFromUtf32(0xE0B1)

    $prompt = ' '
    # PowerLine starts with a space
    Write-Prompt -Object $prompt -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor

    #check the last command state and indicate if failed
    If ($lastCommandFailed)
    {
        $prompt = $prompt + "$($sl.FailedCommandSymbol) "
        Write-Prompt -Object "$($sl.FailedCommandSymbol) " -ForegroundColor $sl.CommandFailedIconForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    }

    #check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
    {
        $prompt = $prompt + "$($sl.ElevatedSymbol) "
        Write-Prompt -Object "$($sl.ElevatedSymbol) " -ForegroundColor $sl.AdminIconForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    }

    $user = [Environment]::UserName
    $path = (Get-Location).Path.Replace($HOME,'~')
    
    $prompt = $prompt + "$user $fancySpacerSymbol $path "
    Write-Prompt -Object "$user " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
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
    Write-Prompt -Object $fancySpacerSymbol -ForegroundColor $sl.PromptBackgroundColor -BackgroundColor $sl.SessionInfoBackgroundColor 

    $backwardSpacerSymbol = [char]::ConvertFromUtf32(0xE0B2)
    $betweenBackwardSpacerSymbol = [char]::ConvertFromUtf32(0xE0B3)
    $date = Get-Date -UFormat %d-%m-%Y
    $timeStamp = Get-Date -UFormat %R
    $leftText = "$backwardSpacerSymbol $date $betweenBackwardSpacerSymbol $timeStamp "

    $remainingWidth = Get-BetweenSpace -promptText $prompt -endText $leftText

    Write-Prompt -Object $backwardSpacerSymbol.PadLeft($remainingWidth - $leftText.length, ' ') -ForegroundColor $sl.PromptBackgroundColor -BackgroundColor $sl.SessionInfoBackgroundColor 
    
    Write-Host " $date $betweenBackwardSpacerSymbol $timeStamp " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor 

    $promptSymbol = [char]::ConvertFromUtf32(0x276F)
    Write-Prompt -Object " $promptSymbol" -ForegroundColor $sl.PromptBackgroundColor
}

$sl = $global:ThemeSettings #local settings

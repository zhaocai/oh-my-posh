#requires -Version 2 -Modules posh-git
$global:AgnosterPromptSettings = New-Object -TypeName PSObject -Property @{
    FancySpacerSymbol                = [char]::ConvertFromUtf32(0xE0B0)
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
    BranchBehindAndAheadStatusSymbol = [char]::ConvertFromUtf32(0x21C5)
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

    $drive = (Get-Drive -path (Get-Location).Path)

    $lastColor = $sl.PromptBackgroundColor

    # PowerLine starts with a space
    Write-Prompt -Object ' ' -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor

    #check the last command state and indicate if failed
    If ($lastCommandFailed)
    {
        Write-Prompt -Object "$($sl.FailedCommandSymbol) " -ForegroundColor $sl.CommandFailedIconForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    }

    #check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
    {
        Write-Prompt -Object "$($sl.ElevatedSymbol) " -ForegroundColor $sl.AdminIconForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    }

    $user = [Environment]::UserName
    Write-Prompt -Object "$user " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.SessionInfoBackgroundColor
    Write-Prompt -Object "$($sl.FancySpacerSymbol) " -ForegroundColor $sl.SessionInfoBackgroundColor -BackgroundColor $sl.PromptBackgroundColor

    # Writes the drive portion
    Write-Prompt -Object "$drive" -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor
    Write-Prompt -Object (Get-ShortPath -path (Get-Location).Path) -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor
    Write-Prompt -Object ' ' -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $sl.PromptBackgroundColor

    $status = Get-VCSStatus
    if ($status)
    {
        $lastColor = Write-FancyVcsBranches -status ($status)
    }

    # Writes the postfix to the prompt
    Write-Prompt -Object $sl.FancySpacerSymbol -ForegroundColor $lastColor

    return ' '
}

function Get-VCSStatus
{
    $status = $null
    $vcs_systems = @{
        'posh-git' = 'Get-GitStatus'
        'posh-hg' = 'Get-HgStatus'
        'posh-svn' = 'Get-SvnStatus'
    }

    foreach ($key in $vcs_systems.Keys)
    {
        $module = Get-Module -Name $key
        if($module -and @($module).Count -gt 0)
        {
            $status = (Invoke-Expression -Command ($vcs_systems[$key]))
            if ($status)
            {
                return $status
            }
        }
    }
    return $status
}


function Write-FancyVcsBranches
{
    param
    (
        [Object]
        $status
    )

    if ($status)
    {
        $branchStatusForegroundColor = $sl.PromptForegroundColor
        $branchStatusBackgroundColor = $sl.GitDefaultColor

        # Determine Colors
        $localChanges = ($status.HasIndex -or $status.HasUntracked -or $status.HasWorking)
        #Git flags
        $localChanges = $localChanges -or (($status.Untracked -gt 0) -or ($status.Added -gt 0) -or ($status.Modified -gt 0) -or ($status.Deleted -gt 0) -or ($status.Renamed -gt 0))
        #hg/svn flags

        if($localChanges)
        {
            $branchStatusBackgroundColor = $sl.GitLocalChangesColor
        }
        if(-not ($localChanges) -and ($status.AheadBy -gt 0))
        {
            $branchStatusBackgroundColor = $sl.GitNoLocalChangesAndAheadColor
        }

        Write-Prompt -Object $sl.FancySpacerSymbol -ForegroundColor $sl.PromptBackgroundColor -BackgroundColor $branchStatusBackgroundColor
        Write-Prompt -Object " $($sl.GitBranchSymbol)" -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor

        $branchStatusSymbol = $null

        if (!$status.Upstream)
        {
            $branchStatusSymbol = $sl.BranchUntrackedSymbol
        }
        elseif ($status.BehindBy -eq 0 -and $status.AheadBy -eq 0)
        {
            # We are aligned with remote
            $branchStatusSymbol = $sl.BranchIdenticalStatusToSymbol
        }
        elseif ($status.BehindBy -ge 1 -and $status.AheadBy -ge 1)
        {
            # We are both behind and ahead of remote
            $branchStatusSymbol = $sl.BranchBehindAndAheadStatusSymbol
        }
        elseif ($status.BehindBy -ge 1)
        {
            # We are behind remote
            $branchStatusSymbol = "$($sl.BranchBehindStatusSymbol)$($status.BehindBy)"
        }
        elseif ($status.AheadBy -ge 1)
        {
            # We are ahead of remote
            $branchStatusSymbol = "$($sl.BranchAheadStatusSymbol)$($status.AheadBy)"
        }
        else
        {
            # This condition should not be possible but defaulting the variables to be safe
            $branchStatusSymbol = '?'
        }

        Write-Prompt -Object (Format-BranchName -branchName ($status.Branch)) -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor

        if ($branchStatusSymbol)
        {
            Write-Prompt  -Object ('{0} ' -f $branchStatusSymbol) -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
        }

        if($spg.EnableFileStatus -and $status.HasIndex)
        {
            Write-Prompt -Object $sl.BeforeIndexSymbol -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor

            if($spg.ShowStatusWhenZero -or $status.Index.Added)
            {
                Write-Prompt -Object "+$($status.Index.Added.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
            if($spg.ShowStatusWhenZero -or $status.Index.Modified)
            {
                Write-Prompt -Object "~$($status.Index.Modified.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
            if($spg.ShowStatusWhenZero -or $status.Index.Deleted)
            {
                Write-Prompt -Object "-$($status.Index.Deleted.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }

            if ($status.Index.Unmerged)
            {
                Write-Prompt -Object "!$($status.Index.Unmerged.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }

            if($status.HasWorking)
            {
                Write-Prompt -Object "$($sl.DelimSymbol) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
        }

        if($spg.EnableFileStatus -and $status.HasWorking)
        {
            if($showStatusWhenZero -or $status.Working.Added)
            {
                Write-Prompt -Object "+$($status.Working.Added.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
            if($spg.ShowStatusWhenZero -or $status.Working.Modified)
            {
                Write-Prompt -Object "~$($status.Working.Modified.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
            if($spg.ShowStatusWhenZero -or $status.Working.Deleted)
            {
                Write-Prompt -Object "-$($status.Working.Deleted.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
            if ($status.Working.Unmerged)
            {
                Write-Prompt -Object "!$($status.Working.Unmerged.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
        }

        if ($status.HasWorking)
        {
            # We have un-staged files in the working tree
            $localStatusSymbol = $sl.LocalWorkingStatusSymbol
        }
        elseif ($status.HasIndex)
        {
            # We have staged but uncommited files
            $localStatusSymbol = $sl.LocalStagedStatusSymbol
        }
        else
        {
            # No uncommited changes
            $localStatusSymbol = $sl.LocalDefaultStatusSymbol
        }

        if ($localStatusSymbol)
        {
            Write-Prompt -Object ('{0} ' -f $localStatusSymbol) -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
        }

        if ($status.StashCount -gt 0)
        {
            Write-Prompt -Object "$($sl.BeforeStashSymbol)$($status.StashCount)$($sl.AfterStashSymbol) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
        }

        if ($WindowTitleSupported -and $spg.EnableWindowTitle)
        {
            if( -not $Global:PreviousWindowTitle )
            {
                $Global:PreviousWindowTitle = $Host.UI.RawUI.WindowTitle
            }
            $repoName = Split-Path -Leaf -Path (Split-Path -Path $status.GitDir)
            $prefix = if ($spg.EnableWindowTitle -is [string])
            {
                $spg.EnableWindowTitle
            }
            else
            {
                ''
            }
            $Host.UI.RawUI.WindowTitle = "$script:adminHeader$prefix$repoName [$($status.Branch)]"
        }

        return $branchStatusBackgroundColor
    }
}

function Format-BranchName
{
    param
    (
        [string]
        $branchName
    )

    if($spg.BranchNameLimit -gt 0 -and $branchName.Length -gt $spg.BranchNameLimit)
    {
        $branchName = ' {0}{1} ' -f $branchName.Substring(0, $spg.BranchNameLimit), $spg.TruncatedBranchSuffix
    }
    return " $branchName "
}

function Test-IsVanillaWindow
{
    if($env:PROMPT -or $env:ConEmuANSI)
    {
        # Console
        return $false
    }
    else
    {
        # Powershell
        return $true
    }
}

function Get-Home
{
    return $HOME
}


function Get-Provider
{
    param
    (
        [string]
        $path
    )

    return (Get-Item $path).PSProvider.Name
}



function Get-Drive
{
    param
    (
        [string]
        $path
    )

    $provider = Get-Provider -path $path

    if($provider -eq 'FileSystem')
    {
        $homedir = Get-Home
        if( $path.StartsWith( $homedir ) )
        {
            return '~\'
        }
        elseif( $path.StartsWith( 'Microsoft.PowerShell.Core' ) )
        {
            $parts = $path.Replace('Microsoft.PowerShell.Core\FileSystem::\\','').Split('\')
            return "\\$($parts[0])\$($parts[1])\"
        }
        else
        {
            $root = (Get-Item $path).Root
            if($root)
            {
                return $root
            }
            else
            {
                return $path.Split(':\')[0] + ':\'
            }
        }
    }
    else
    {
        return (Get-Item $path).PSDrive.Name + ':\'
    }
}

function Test-IsVCSRoot
{
    param
    (
        [object]
        $dir
    )

    return (Test-Path -Path "$($dir.FullName)\.git") -Or (Test-Path -Path "$($dir.FullName)\.hg") -Or (Test-Path -Path "$($dir.FullName)\.svn")
}

function Get-ShortPath
{
    param
    (
        [string]
        $path
    )

    $provider = Get-Provider -path $path

    if($provider -eq 'FileSystem')
    {
        $result = @()
        $dir = Get-Item $path

        while( ($dir.Parent) -And ($dir.FullName -ne $HOME) )
        {
            $isVcsRoot = Test-IsVCSRoot -dir $dir
            if( (Test-IsVCSRoot -dir $dir) -Or ($result.length -eq 0) )
            {
                $result = ,$dir.Name + $result
            }
            else
            {
                $result = ,$sl.TruncatedFolderSymbol + $result
            }

            $dir = $dir.Parent
        }
        return $result -join '\'
    }
    else
    {
        return $path.Replace((Get-Drive -path $path), '')
    }
}

function Show-AgnosterColors
{
    Write-Host -Object ''
    Write-ColorPreview -text 'GitDefaultColor                  ' -color $sl.GitDefaultColor
    Write-ColorPreview -text 'GitLocalChangesColor             ' -color $sl.GitLocalChangesColor
    Write-ColorPreview -text 'GitNoLocalChangesAndAheadColor   ' -color $sl.GitNoLocalChangesAndAheadColor
    Write-ColorPreview -text 'PromptForegroundColor            ' -color $sl.PromptForegroundColor
    Write-ColorPreview -text 'PromptBackgroundColor            ' -color $sl.PromptBackgroundColor
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

$sl = $global:AgnosterPromptSettings #local settings
$spg = $global:GitPromptSettings #Posh-Git settings
Start-Up # Executes the Start-Up function, better encapsulation

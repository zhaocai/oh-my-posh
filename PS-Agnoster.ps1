$global:AgnosterPromptSettings = New-Object PSObject -Property @{
  FancySpacerSymbol = [char]::ConvertFromUtf32(0xE0B0)
  GitBranchSymbol = [char]::ConvertFromUtf32(0xE0A0)
  FancyXSymbol = [char]::ConvertFromUtf32(0x2716)
  TruncatedFolderText = '..'
  BeforeStashText = '{'
  AfterStashText = '}'
  DelimText = '|'
  LocalWorkingStatusSymbol = '!'
  LocalStagedStatusSymbol = '~'
  BranchUntrackedSymbol = [char]::ConvertFromUtf32(0x2262)
  BranchIdenticalStatusToSymbol = [char]::ConvertFromUtf32(0x2263) # Three horizontal lines
  BranchAheadStatusSymbol = [char]::ConvertFromUtf32(0x2191) # Up arrow
  BranchBehindStatusSymbol = [char]::ConvertFromUtf32(0x2193) # Down arrow
  BranchBehindAndAheadStatusSymbol = [char]::ConvertFromUtf32(0x21C5) # Up & Down arrow
  ElevatedSymbol = [char]::ConvertFromUtf32(0x26A1) #lightning symbol
  GitDefaultColor = [ConsoleColor]::DarkCyan
  GitLocalChangesColor = [ConsoleColor]::DarkGreen
  GitNoLocalChangesAndAheadColor = [ConsoleColor]::DarkGray
  PromptForegroundColor = [ConsoleColor]::Black
  PromptBackgroundColor = [ConsoleColor]::DarkBlue
}

<#
.SYNOPSIS
Method called at each launch of Powershell

.DESCRIPTION
Sets up things needed in each console session, asside from prompt
#>
function Start-Up{

    if(Test-Path -Path ~\.last) {
        (Get-Content -Path ~\.last) | set-location
       Remove-Item -Path ~\.last
    }

    # Makes git diff work
    $env:TERM = "msys"

    if(Get-Module Posh-Git) {
        Start-SshAgent -Quiet
    }
}

<#
.SYNOPSIS
Generates the prompt before each line in the console
#>
function Prompt {
    $drive = (Get-Drive (Get-Location).Path)

    switch -wildcard ($drive){
        "C:\" { $driveColor = $sl.PromptBackgroundColor }
        "~\"  { $driveColor = $sl.PromptBackgroundColor }
        "\\*" { $driveColor = $sl.PromptBackgroundColor }
    }

    $lastColor = $driveColor

    # PowerLine starts with a space
    Write-Prompt " " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $driveColor

    #check for elevated prompt
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
      Write-Prompt "$($sl.ElevatedSymbol) " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $driveColor
    }

    # Writes the drive portion
    Write-Prompt "$drive" -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $driveColor
    Write-Prompt (Shorten-Path (Get-Location).Path) -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $driveColor
    Write-Prompt " " -ForegroundColor $sl.PromptForegroundColor -BackgroundColor $driveColor

    if(Vanilla-Window){ #use the builtin posh-output
        Write-VcsStatus
    } else { #get ~fancy~
        $status = Get-VCSStatus
        if ($status) {
            $lastColor = Write-Fancy-Vcs-Branches($status);
        }
    }

    # Writes the postfix to the prompt
    if(Vanilla-Window) {
        Write-Host -Object ">" -n
    } else {
        Write-Prompt $sl.FancySpacerSymbol -ForegroundColor $lastColor
    }

    return " "
}

function Get-VCSStatus{
    $status = $null
    $vcs_systems = @{"posh-git"  = "Get-GitStatus";
                     "posh-hg"   = "Get-HgStatus";
                     "posh-svn"  = "Get-SvnStatus"
                    }

    foreach ($key in $vcs_systems.Keys) {
        $module = Get-Module -Name $key;
        if($module -and @($module).Count -gt 0){
            $status = (Invoke-Expression -Command ($vcs_systems[$key]));
            if ($status) {
                return $status
            }
        }
    }
    return $status
}


function Write-Fancy-Vcs-Branches($status) {
    if ($status) {

        $branchStatusForegroundColor = $sl.PromptForegroundColor
        $branchStatusBackgroundColor = $sl.GitDefaultColor

        # Determine Colors
        $localChanges = ($status.HasIndex -or $status.HasUntracked -or $status.HasWorking); #Git flags
        $localChanges = $localChanges -or (($status.Untracked -gt 0) -or ($status.Added -gt 0) -or ($status.Modified -gt 0) -or ($status.Deleted -gt 0) -or ($status.Renamed -gt 0)); #hg/svn flags

        if($localChanges) {
          $branchStatusBackgroundColor = $sl.GitLocalChangesColor
        }
        if(-not ($localChanges) -and ($status.AheadBy -gt 0)){
          $branchStatusBackgroundColor = $sl.GitNoLocalChangesAndAheadColor
        }

        Write-Prompt $sl.FancySpacerSymbol -ForegroundColor $driveColor -BackgroundColor $branchStatusBackgroundColor
        Write-Prompt " $($sl.GitBranchSymbol)" -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor

        $branchStatusSymbol = $null

        if (!$status.Upstream) {
            $branchStatusSymbol = $sl.BranchUntrackedSymbol
        } elseif ($status.BehindBy -eq 0 -and $status.AheadBy -eq 0) {
            # We are aligned with remote
            $branchStatusSymbol = $sl.BranchIdenticalStatusToSymbol
        } elseif ($status.BehindBy -ge 1 -and $status.AheadBy -ge 1) {
            # We are both behind and ahead of remote
            $branchStatusSymbol = $sl.BranchBehindAndAheadStatusSymbol
        } elseif ($status.BehindBy -ge 1) {
            # We are behind remote
            $branchStatusSymbol = $sl.BranchBehindStatusSymbol
        } elseif ($status.AheadBy -ge 1) {
            # We are ahead of remote
            $branchStatusSymbol = $sl.BranchAheadStatusSymbol
        } else {
            # This condition should not be possible but defaulting the variables to be safe
            $branchStatusSymbol = "?"
        }

        Write-Prompt (Format-BranchName($status.Branch)) -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor

        if ($branchStatusSymbol) {
            Write-Prompt  ("{0} " -f $branchStatusSymbol) -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
        }

        if($spg.EnableFileStatus -and $status.HasIndex) {
            Write-Prompt $sl.BeforeIndexText -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor

            if($spg.ShowStatusWhenZero -or $status.Index.Added) {
              Write-Prompt "+$($status.Index.Added.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
            if($spg.ShowStatusWhenZero -or $status.Index.Modified) {
              Write-Prompt "~$($status.Index.Modified.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
            if($spg.ShowStatusWhenZero -or $status.Index.Deleted) {
              Write-Prompt "-$($status.Index.Deleted.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }

            if ($status.Index.Unmerged) {
                Write-Prompt "!$($status.Index.Unmerged.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }

            if($status.HasWorking) {
                Write-Prompt "$($sl.DelimText) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
        }

        if($spg.EnableFileStatus -and $status.HasWorking) {
            if($showStatusWhenZero -or $status.Working.Added) {
              Write-Prompt "+$($status.Working.Added.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
            if($spg.ShowStatusWhenZero -or $status.Working.Modified) {
              Write-Prompt "~$($status.Working.Modified.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
            if($spg.ShowStatusWhenZero -or $status.Working.Deleted) {
              Write-Prompt "-$($status.Working.Deleted.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
            if ($status.Working.Unmerged) {
                Write-Prompt "!$($status.Working.Unmerged.Count) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
            }
        }

        if ($status.HasWorking) {
            # We have un-staged files in the working tree
            $localStatusSymbol = $sl.LocalWorkingStatusSymbol
        } elseif ($status.HasIndex) {
            # We have staged but uncommited files
            $localStatusSymbol = $sl.LocalStagedStatusSymbol
        } else {
            # No uncommited changes
            $localStatusSymbol = $sl.LocalDefaultStatusSymbol
        }

        if ($localStatusSymbol) {
            Write-Prompt ("{0} " -f $localStatusSymbol) -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
        }

        if ($status.StashCount -gt 0) {
             Write-Prompt "$($sl.BeforeStashText)$($status.StashCount)$($sl.AfterStashText) " -BackgroundColor $branchStatusBackgroundColor -ForegroundColor $branchStatusForegroundColor
        }

        if ($WindowTitleSupported -and $spg.EnableWindowTitle) {
            if( -not $Global:PreviousWindowTitle ) {
                $Global:PreviousWindowTitle = $Host.UI.RawUI.WindowTitle
            }
            $repoName = Split-Path -Leaf (Split-Path $status.GitDir)
            $prefix = if ($spg.EnableWindowTitle -is [string]) { $spg.EnableWindowTitle } else { '' }
            $Host.UI.RawUI.WindowTitle = "$script:adminHeader$prefix$repoName [$($status.Branch)]"
        }

        return $branchStatusBackgroundColor
    }
}

function Format-BranchName($branchName){
    if($spg.BranchNameLimit -gt 0 -and $branchName.Length -gt $spg.BranchNameLimit)
    {
        $branchName = " {0}{1} " -f $branchName.Substring(0,$spg.BranchNameLimit), $spg.TruncatedBranchSuffix
    }
    return " $branchName "
}

function Vanilla-Window{
    if($env:PROMPT -or $env:ConEmuANSI){
        # Console
        return $false
    } else {
        # Powershell
        return $true
    }
}

function Get-Home
{
    return $HOME;
}


function Get-Provider( [string] $path ){
    return (Get-Item $path).PSProvider.Name
}



function Get-Drive( [string] $path ) {
    $provider = Get-Provider $path

    if($provider -eq "FileSystem"){
        $homedir = Get-Home;
        if( $path.StartsWith( $homedir ) ) {
            return "~\"
        } elseif( $path.StartsWith( "Microsoft.PowerShell.Core" ) ){
            $parts = $path.Replace("Microsoft.PowerShell.Core\FileSystem::\\","").Split("\")
            return "\\$($parts[0])\$($parts[1])\"
        } else {
            $root = (Get-Item $path).Root
            if($root){
                return $root
            } else {
                return $path.Split(":\")[0] + ":\"
            }
        }
    } else {
        return (Get-Item $path).PSDrive.Name + ":\"
    }
}

function Is-VCSRoot( $dir ) {
    return (Get-ChildItem -Path $dir.FullName -force .git) `
       -Or (Get-ChildItem -Path $dir.FullName -force .hg) `
       -Or (Get-ChildItem -Path $dir.FullName -force .svn) `
}

function Shorten-Path([string] $path) {
    $provider = Get-Provider $path

    if($provider -eq "FileSystem"){
        $result = @()
        $dir = Get-Item $path

        while( ($dir.Parent) -And ($dir.FullName -ne $HOME) ) {

            if( (Is-VCSRoot $dir) -Or ($result.length -eq 0) ) {
                $result = ,$dir.Name + $result
            } else {
                $result = ,$sl.TruncatedFolderText + $result
            }

            $dir = $dir.Parent
        }
        return $result -join "\"
    } else {
        return $path.Replace((Get-Drive $path), "")
    }

}

function Agnoster-Colors {
    Write-Host "GitDefaultColor                " -nonewline
    Write-Host "       " -backgroundcolor $sl.GitDefaultColor
    Write-Host "GitLocalChangesColor           " -nonewline
    Write-Host "       " -backgroundcolor $sl.GitLocalChangesColor
    Write-Host "GitNoLocalChangesAndAheadColor " -nonewline
    Write-Host "       " -backgroundcolor $sl.GitNoLocalChangesAndAheadColor
    Write-Host "PromptForegroundColor          " -nonewline
    Write-Host "       " -backgroundcolor $sl.PromptForegroundColor
    Write-Host "PromptBackgroundColor          " -nonewline
    Write-Host "       " -backgroundcolor $sl.PromptBackgroundColor
}

$sl = $global:AgnosterPromptSettings #local settings
$spg = $global:GitPromptSettings #Posh-Git settings
$driveColor = $sl.DriveDefaultColor
Start-Up # Executes the Start-Up function, better encapsulation

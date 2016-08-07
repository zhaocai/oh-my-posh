# PSColor default settings
$global:PSColor = @{
    File = @{
        Default    = @{ Color = 'White' }
        Directory  = @{ Color = 'DarkBlue'}
        Hidden     = @{ Color = 'Gray'; Pattern = '^\.' } 
        Code       = @{ Color = 'Magenta'; Pattern = '\.(java|c|cpp|cs|js|css|html)$' }
        Executable = @{ Color = 'Red'; Pattern = '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg)$' }
        Text       = @{ Color = 'White'; Pattern = '\.(txt|cfg|conf|ini|csv|log|config|xml|yml|md|markdown)$' }
        Compressed = @{ Color = 'DarkGreen'; Pattern = '\.(zip|tar|gz|rar|jar|war)$' }
    }
    Service = @{
        Default = @{ Color = 'White' }
        Running = @{ Color = 'DarkGreen' }
        Stopped = @{ Color = 'DarkYellow' }     
    }
    Match = @{
        Default    = @{ Color = 'White' }
        Path       = @{ Color = 'Cyan'}
        LineNumber = @{ Color = 'DarkGreen' }
        Line       = @{ Color = 'White' }
    }
}

# Set sane defaults
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
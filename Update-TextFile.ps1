<#
.SYNOPSIS
    Replace a string in the given text file
.EXAMPLE
    PS C:\> Update-TextFile .\config.xml -o 1_0_1 -n 1_0_2
    Replace the string 1_0_1 in the given file as 1_0_2
.NOTES
    Accepts a single text file only.
    Use -Verbose and -WhatIf to find out details.
#>
function Update-TextFile {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true,
                   Position = 0,
                   HelpMessage="Path to text file that need update")]
        [Alias("F")]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]
        $path,

        [Parameter(Mandatory=$true,
                   HelpMessage="Old string to be replaced from")]
        [Alias("O")]
        [ValidateNotNullOrEmpty()]
        [string]
        $oldString,

        [Parameter(Mandatory=$true,
                   HelpMessage="New string to be replaced to")]
        [Alias("N")]
        [ValidateNotNullOrEmpty()]
        [string]
        $newString
    )
    begin {
        Write-Verbose "[$((Get-Date).TimeofDay)] Beginning $($MyInvocation.MyCommand.Name)"
    }
    process {
        # resolve any given relative path
        $fullPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($path)

        Write-Verbose "oldString: $oldString"
        Write-Verbose "newString: $newString"

        Write-Host "Updating file $fullPath"
        if ($PSCmdlet.ShouldProcess($fullPath)) {
            # perform update, brackets required before Get-Content!
            (Get-Content $fullPath -encoding UTF8 |
                ForEach-Object {$_ -replace $oldString, $newString }
            ) | Set-Content $fullPath -encoding UTF8
            Write-Host "Updated file $fullPath"
        }
    }
    end {
        Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($MyInvocation.MyCommand.Name)"
        Write-Host
    }
}

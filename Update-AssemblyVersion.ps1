<#
.SYNOPSIS
    Update assembly version and file version in .NET project assembly info files.
.DESCRIPTION
    For the given search path, it tries to find all possible .NET project assembly info files and update them.
.EXAMPLE
    PS C:\> Update-AssemblyVersion -v 1.2.3.4 -p c:\temp
    For all possible files in c:\temp and its sub-directories, update versions as 1.2.3.4.
.EXAMPLE
    PS C:\> Update-AssemblyVersion -v 1.2.3 -p .
    For all possible files in the current directory and its sub-directories, update versions as 1.2.3.
.NOTES
    Version should be in form of <major>.<minor>.<build>.<revision>.
    Candidate file names could be in form of *AssemblyInfo*.cs or *AssemblyInfo*.vb.
    Use -Verbose and -WhatIf to find out details.
#>
function Update-AssemblyVersion {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true,
                   Position = 0,
                   HelpMessage="New version to be set")]
        [Alias("V")]
        [ValidatePattern("[0-9]+(\.([0-9]+|\*)){1,3}")]
        [string]
        $version,

        [Parameter(Mandatory=$true,
                   HelpMessage="Path to search for assembly info files")]
        [Alias("P")]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]
        $path
    )
    begin {
        Write-Verbose "[$((Get-Date).TimeofDay)] Beginning $($MyInvocation.MyCommand.Name)"
    }
    process {
        # resolve any given relative path
        $fullPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($path)

        $newVersion = 'AssemblyVersion("' + $version + '")';
        $newFileVersion = 'AssemblyFileVersion("' + $version + '")';
        $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
        $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'

        Write-Verbose "newVersion: $newVersion"
        Write-Verbose "newFileVersion: $newFileVersion"
        Write-Verbose "assemblyVersionPattern: $assemblyVersionPattern"
        Write-Verbose "fileVersionPattern: $fileVersionPattern"

        Write-Host "Start finding candidate files..."
        Get-ChildItem -Path $fullPath -Recurse -Filter "*AssemblyInfo*" -Include "*.cs","*.vb" |
            ForEach-Object {
                # detailed message for each file
                $currentFile = $_.FullName
                Write-Host "Updating version $version in file $currentFile"

                if ($PSCmdlet.ShouldProcess($version)) {
                    # perform version update, brackets required before Get-Content!
                    (Get-Content $currentFile -encoding UTF8 |
                        ForEach-Object {$_ -replace $assemblyVersionPattern, $newVersion } |
                        ForEach-Object {$_ -replace $fileVersionPattern, $newFileVersion }
                    ) | Set-Content $currentFile -encoding UTF8
                    Write-Host "Updated file $currentFile"
                }
            }
    }
    end {
        Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($MyInvocation.MyCommand.Name)"
        Write-Host
    }
}

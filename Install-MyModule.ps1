# import helper function Validate-Folder
. "$PSScriptRoot\Validate-Folder.ps1"

<#
.SYNOPSIS
  Find possible module files and copy them to current users WindowsPowershell modules folder
.DESCRIPTION
  Auto discover the first available *.psd1 file, and use its base name as the powershell module name
  Auto create relevant folder structure in $env:USERPROFILE\Documents\WindowsPowerShell
  Auto copy all relevant module files (*.ps1, *.psd1, *.psm1) over
.EXAMPLE
  PS C:\> Install-MyModule .
  Find the module in the current folder and copy all scirpts etc over
.NOTES
  This function assumes both *.psd1 or *.psm1 files have the same base file name
#>
function Install-MyModule() {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true,
                   Position = 0,
                   HelpMessage="Source path of the module manifest file (*.psd1)")]
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
        $fullSourcePath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($path)

        # finding module manifest file or module file
        $manifestFiles = @(Get-Item "$($fullSourcePath)\*.*" -Include "*.psd1","*.psm1")
        if ($manifestFiles.Length -eq 0) {
            Write-Error "Could not find any module files (*.psd1 or *.psm1)"
            break
        }

        # The name of your module should match the basename of the first PSD1/PSM1 file.
        $moduleName = $manifestFiles[0].BaseName      

        $psUserPath = "$env:USERPROFILE\Documents\WindowsPowerShell"
        $isValid = Validate-Folder $psUserPath -Verbose
        if ($isValid -eq $false) {
            break
        }

        $psUserModulePath = "$($psUserPath)\Modules"
        $isValid = Validate-Folder $psUserModulePath -Verbose
        if ($isValid -eq $false) {
            break
        }

        $targetModulePath = "$($psUserModulePath)\$($ModuleName)"
        Write-Host "Start installing module $moduleName to '$targetModulePath'"

        if ($PSCmdlet.ShouldProcess($ModuleName)) {

            $isValid = Validate-Folder $targetModulePath -Verbose
            if ($isValid -eq $false) {
                break
            }

            # safety check before deleting files
            if ((Test-Path $targetModulePath) -and $targetModulePath.EndsWith($moduleName)) {

                Write-Host "Cleaning '$targetModulePath'"
                Remove-Item $targetModulePath\* -Recurse -Force

                # some items will NOT be published with the module
                $excludes = @(
                    'Tests',
                    '.git*',
                    '.vs*'
                )

                Write-Host "Copying files and sub-folders to '$targetModulePath'"
                Copy-Item -Path $fullSourcePath\* -Destination $targetModulePath -Verbose -Recurse -Exclude $excludes
            }
        }
    }
    end {
        Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($MyInvocation.MyCommand.Name)"
        Write-Host
    }
}

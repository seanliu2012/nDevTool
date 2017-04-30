<# 
 .SYNOPSIS
  Function to validate that a folder exists, creates folder if missing

 .DESCRIPTION
  Function to validate that a folder exists, creates folder if missing
  If the -NoCreate switch is used the function will not create a missing folder
  The function will create missing subfolders as well

 .PARAMETER FolderName
  This can be local like 'c:\folder 1\folder 2' 
  or UNC path like '\\server\share\folder 1\folder 2'
  
 .PARAMETER NoCreate
  This switch will insruct the function to NOT create the folder if missing

 .OUTPUTS 
  The function returns a TRUE/FALSE value
  The function returns TRUE if:
    - The folder exists
    - The folder did not exist but was created by the function
  The function will return FALSE if:
    - The folder doesn't exist and the -NoCreate switch is used
    - The folder doesn't exist and the function failed to create it

 .EXAMPLE
  Validate-Folder -FolderName c:\folder1
  This example checks if folder c:\folder1 exists, creates it if not, 
  returns TRUE if exists or created, returns FALSE if failed to create missing folder

 .EXAMPLE
  Validate-Folder -FolderName 'c:\folder 2' -NoCreate
  This example checks if 'c:\folder 2' exists, return TRUE if it does, FALSE if it doesn't

 .EXAMPLE
  if (Validate-Folder 'c:\folder 1\sub 2') { 'hi' | Out-File 'c:\folder 1\sub 2\file.txt' }
  This example checks if folder 'c:\folder 1\sub 2' exists,
  creates it if it doesn't,
  creates file 'c:\folder 1\sub 2\file.txt', and
  writes 'hi' to it

 .EXAMPLE
  @('c:\folder1','\\server\share\folder 4') | % { Validate-Folder $_ -Verbose }
  This example validates if the folders in the input array exist, creates them if they don't

 .NOTES
  Sam Boutros - 5 August 2016 - v1.0
  For more information see 
  https://superwidgets.wordpress.com/2016/08/05/powershell-script-to-validate-if-a-folder-exists-creates-it-if-not-creates-subfolders-if-needed/

#>
function Validate-Folder {
    [CmdletBinding(ConfirmImpact='Low')] 
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$true,
                   ValueFromPipeLineByPropertyName=$true,
                   Position=0)]
        [String]
        $FolderName, 
        
        [Parameter(Mandatory=$false,
                   Position=1)]
        [Switch]
        $NoCreate = $false
    )

    if ($FolderName.Length -gt 254) {
        Write-Error "Folder name '$FolderName' is too long - ($($FolderName.Length)) characters"
        break
    }
    if (Test-Path $FolderName) {
        Write-Verbose "Folder '$FolderName' exists"
        $true
    } else {
        Write-Verbose "Folder '$FolderName' does not exist"
        if ($NoCreate) {
            $false
            break  
        } else {
            Write-Verbose "Creating folder '$FolderName'"
            try {
                New-Item -Path $FolderName -ItemType directory -Force -ErrorAction Stop | Out-Null
                Write-Verbose "Successfully created folder '$FolderName'"
                $true
            } catch {
                Write-Error "Failed to create folder '$FolderName'"
                $false
            }
        }
    }
}

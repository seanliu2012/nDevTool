<#
.SYNOPSIS
    Update an element or attribute value in the given xml file
.DESCRIPTION
    Update an element or attribute value in the given xml file based on the given xPath search pattern
.EXAMPLE
    PS C:\> Update-XmlFile -file .\test.xml -xpath "/root/foo[@a1="bar"]/@a1" -value "new value"
    For the given xml file, it try to update the xml content based on the xpath query.
    Sample test.xml: <root><foo a1="bar" /></root>.
    Updated test.xml: <root><foo a1="new value" /></root>.
.NOTES
    Accepts a single xml file only.
    Use -Verbose and -WhatIf to find out details.
#>
function Update-XmlFile {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true,
                   Position=0,
                   HelpMessage="Path to an xml file")]
        [Alias("F")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            if ((Get-Content $_) -as [xml]) {
                $true
            }
            else {
                throw "Please provide a valid xml file."
            }
        })]
        [string]
        $file,

        [Parameter(Mandatory=$true,
                   HelpMessage="xpath for finding target element or attribute")]
        [Alias("X")]
        #[ValidateNotNullOrEmpty]
        [string]
        $xpath,

        [Parameter(Mandatory=$true,
                   HelpMessage="new value to be set")]
        [Alias("V")]
        [string]
        $value
    )
    begin {
        Write-Verbose "[$((Get-Date).TimeofDay)] Beginning $($MyInvocation.MyCommand.Name)"
    }
    process {
        # resolve any given relative path
        $fullPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($file)

        Write-Verbose "Reading xml content in $fullPath"
        $xml = [xml](Get-Content $fullPath)
        # for older version of PowerShell, we may use below method
        # $xml = New-Object xml
        # $xml.PreserveWhitespace = $true
        # $xml.Load($fullPath)

        Write-Verbose "Selecting nodes using xpath: $xpath"
        $nodes = $xml.SelectNodes($xpath)

        if ($nodes.Count -gt 0) {
            Write-Verbose "Found $($nodes.Count) node(s)"

            foreach ($node in $nodes) {
                if ($node -ne $null) {
                    if ($node.NodeType -eq "Element") {
                        $node.InnerXml = $value
                    }
                    else {
                        $node.Value = $value
                    }
                }
            }

            Write-Host "Updating xml content in $file"
            if ($PSCmdlet.ShouldProcess($file)) {
                # write updated xml back into file
                $xml.Save($fullPath)
                Write-Host "Updated file $fullPath"
            }
        }
        else {
            Write-Warning "Could not find a node by searching xpath: $xpath"
        }
    }
    end {
        Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($MyInvocation.MyCommand.Name)"
        Write-Host
    }
}

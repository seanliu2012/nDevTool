# nDevTool
My collection of power shell scripts for .NET developement
 * Requires PowerShell version 4 or later.

### Setting up the module

Steps of setting up
```shell
$ git clone https://github.com/seanliu2012/nDevTool nDevTool
$ cd .\nDevTool
$ . .\Install-MyModule.ps1  # auto loads Validate-Folder.ps1 as well
$ Install-MyModule .
```

### Sample XML updates

For all possible files in the current directory and its sub-directories, update versions as 1.2.3
```shell
$ Update-AssemblyVersion -v 1.2.3 -p .
```

### Sample XML updates

What could happen if updating the security mode attribute in Binding.Config
```shell
$ Update-XmlFile -file .\Binding.config `
$                -xpath "/bindings/basicHttpBinding/binding[@name='BasicHttpBinding_ITwoWayAsync']/security/@mode" `
$                -value "TransportCredentialOnly" `
$                -verbose -WhatIf
```

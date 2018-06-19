<#********************************************Description********************************************

This script is an example of how to update HPOACmdlets module and help

***************************************************************************************************#>
# Getting the current module version and help version information on the system
Get-HPOAModuleVersion

# Updating help to the latest version using the standard PowerShell cmdlet
Update-Help -Module HPOACmdlets -Verbose

# Checking and updating the module
Update-HPOAModuleVersion
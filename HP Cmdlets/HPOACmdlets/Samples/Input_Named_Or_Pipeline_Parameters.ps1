<#********************************************Description********************************************

This script is an example of how to input named or pipeline parameter values for a cmdlet.

***************************************************************************************************#>

###---------------------------------------------Examples of Using Named Parameters---------------------------------------------###
#Example 1: single OA
$connection=Connect-HPOA -OA 192.168.1.1 -Username user1 -Password pwd1
Get-HPOAServerName -Connection $connection 

#Example 2: multiple OA with same username and password / Credential
$OA1 = "192.168.1.1"
$OA2 = "192.168.1.3"
$username = "user"
$password = "pwd"
$credential  = Get-Credential -Message "Please input username and password"
$connection1 = Connect-HPOA -OA $OA1 -Username $username -Password $password
$connection2 = Connect-HPOA -OA $OA2 -Username $username -Password $password
$connection3 = Connect-HPOA -OA $OA1 -Credential $credential
$connection4 = Connect-HPOA -OA $OA2 -Credential $credential
Get-HPOAServerName -Connection @($connection1, $connection2)
Get-HPOAServerName -Connection @($connection3, $connection4)

#Example 3: multiple OA with different username and password / Credential
$OA1 = "192.168.1.1"
$OA2 = "192.168.1.2"
$OA3 = "192.168.1.3"
$OA4 = "192.168.1.4"
$user1 = "user1"
$user2 = "user2"
$pwd1 = "pwd1"
$pwd2 = "pwd2"
$credential1 = Get-Credential -Message "Please input username and password"
$credential2 = Get-Credential -Message "Please input username and password"
$connection1 = Connect-HPOA -OA $OA1 -Username $user1 -Password $pwd1
$connection2 = Connect-HPOA -OA $OA2 -Username $user2 -Password $pwd2
$connection3 = Connect-HPOA -OA $OA3 -Credential $credential1
$connection4 = Connect-HPOA -OA $OA4 -Credential $credential2
Get-HPOAServerName -Connection @($connection1, $connection2)
Get-HPOAServerName -Connection @($connection3, $connection4)


###---------------------------------------------Examples of Using Piped Parameters---------------------------------------------###
#Example 1: Pipe only Connection
$connection = Connect-HPOA -OA $OA -Username $user -Password $pwd
$connection |  Get-HPOAServerName

$connection1 = Connect-HPOA -OA $OA1 -Username $user1 -Password $pwd1
$connection2 = Connect-HPOA -OA $OA2 -Username $user2 -Password $pwd2
@($connection1, $connection2) | Get-HPOAServerName

#Example 2: Pipe a PSObject with multiple OA servers and with same username and password
$p = New-Object -TypeName PSObject -Property @{ "OA"= @("192.168.1.1","192.168.1.3");"Username"="user"; "Password"="pwd" }
$p | Connect-HPOA | Get-HPOAServerName

#Example 3: Pipe a PSObject with multiple OA servers with different username and password
$p = New-Object -TypeName PSObject -Property @{ "OA"= @("192.168.1.1","192.168.1.3");"Username"=@("user1","user2"); "Password"=@("pwd1","pwd2") }
$p | Connect-HPOA | Get-HPOAServerName

#Example 4: Pipe multi-PSObject with multiple OA servers with different parameters
$p1 = New-Object -TypeName PSObject -Property @{
    OA = "192.168.1.1"
    username = "user1"
    password = "pwd1"
}
$p2 = New-Object -TypeName PSObject -Property @{
    OA = "192.168.1.3"
    Credential = Get-Credential -Message "Please enter the password" -UserName "user2"
}
$Connection = @($p1,$p2) | Connect-HPOA
$Connection | Get-HPOAServerName 


###---------------------------------------------Examples of Interactive Input for Mandatory Parameters---------------------------------------------###
#Example1: Pipe multiple servers but username and password is provided for only one server
# You will be asked to input values for mandatory parameters which do not have default values. For example Username and Password for servers 192.168.1.2 and 192.168.1.3
# You will NOT be asked to input value for mandatoty parameters with default values, such as "Bay"
$connection1 = Connect-HPOA -OA $OA1 -Username $user1 -Password $pwd1
$connection2 = Connect-HPOA -OA $OA2 -Username $user2 -Password $pwd2
$connection3 = Connect-HPOA -OA $OA3 -Username $user3 -Password $pwd3

$p1 = New-Object -TypeName PSObject -Property @{
    Connection = $connection1
    Target = "OA"
}
$p2 = New-Object -TypeName PSObject -Property @{
    Connection = $connection2
    Target = "iLO"
}
$p3 = New-Object -TypeName PSObject -Property @{
    Connection = $connection3
    Target = "Server"
}
$list = @($p1,$p2,$p3) 
$list | Get-HPOASysLog
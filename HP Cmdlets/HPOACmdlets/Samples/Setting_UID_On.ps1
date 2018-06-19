<#********************************************Description********************************************

This script is an example of how to get and set UIDs for server in an enclosure

***************************************************************************************************#>

$con = Connect-HPOA -OA 192.168.242.63 -Username username -Password password

#get UIDs and display them
$srvs = Get-HPOAServerList $con
foreach ($server in $srvs.ServerList) {
	if ($server.UID -match '^o(n|ff)$' ) {
		"Bay $($server.Bay) UID is $($server.UID)."
	}
}

#set the server UIDs for all server to On
foreach ($server in $srvs.ServerList) {
	if ($server.UID -match '^o(n|ff)$') {
		if ($server.UID -like 'off') {
			Set-HPOAUID $con -Bay $server.Bay -UIDControl On -Target Server
		}
	}
}

#get UIDs and display them again
sleep 10
foreach ($server in $srvs.ServerList) {
	if ($server.UID -match '^o(n|ff)$' ) {
		"Bay $($server.Bay) UID is $($server.UID)."
	}
}

Disconnect-HPOA $con
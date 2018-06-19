#setting variable computer name
$computer = $env:computername
#$user = read-host -prompt "Input User Name"

#$computer = "ID-L-MZENITHA"
#$user = "MIA.ZENITHA"

if(test-connection -computername $computer -count 2 -quiet){
	"====="
	"$computer is pinging"
	"Now checking settings..."
	
	$workdir = "\\$computer\c$\installer\"
	# Check if work directory exists if not create it
	If (Test-Path -Path $workdir -PathType Container){
		Write-Host "$workdir already exists" -ForegroundColor Red
	}ELSE{
		New-Item -Path $workdir  -ItemType directory
	}

	#get computer model	
	$computermodel = (Get-WmiObject -Class Win32_ComputerSystem -computername $computer).model
	#getting computer settings based on classes
	$ctime = Get-WmiObject -Class win32_timezone -ComputerName $computer
	$cpnp = Get-WmiObject -class Win32_PnPSignedDriver -ComputerName $computer
	$chot = get-hotfix -computername $computer
	$cprod = get-wmiobject -class win32_product -computername $computer
	$cserv = get-service -computername $computer
	#$copt = get-windowsoptionalfeature -online -featurename smb1protocol
	$copt = Get-WmiObject -query "select * from Win32_OptionalFeature where name = 'SMB1PROTOCOL'" -computername $computer

	#activate windows
	if(Get-WmiObject SoftwareLicensingProduct -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" -Property LicenseStatus -computername $computer | where licensestatus -eq 1) {
		"- Windows activated > OK"
	} else {
		"- !!! Windows not yet activated !!!"
		"- Will not try to do this automatically"
	}
	
	#Check timezone
	if ($ctime.Caption -like "*Jakarta*") {
		"- Time zone > OK"
	} else {
		"- !!! Time Zone incorrect !!!"
		"Will try to fix this automatically"	
		Invoke-Command -ComputerName $computer -ScriptBlock {tzutil.exe /s "SE Asia Standard Time"}
		$zone = "SE Asia Standard Time"
		try{
			Invoke-Command -ComputerName $computer -ScriptBlock {tzutil.exe /s $args[0]} -ErrorAction Stop -ArgumentList $Zone 
            Write-verbose "On $computer time zone is now set to $zone" -Verbose
		}catch{
			Write-error "Failed to set $computer time zone to $zone, Kindly check if Remoting and Access is enabled on computer" -Verbose 
		}
	}

	#check ms17-010
	#what to check: kb4012213 or kb4012216 or later (what's the kb code?)
	if($chot.hotfixid -eq "kb4012213" -or $chf.hotfixid -eq "kb4012216") {
		"- Anti Wannacry > OK"
	} else {
		"- !!! Anti Wannacry windows hotfix not exist !!!"
	}

	#Microsoft Visual C++ 2015 Redistributables 64 bit
	if((get-wmiobject -class win32_product -computername $computer).name -like "*Visual C++ 2015 x64*"){
		"Microsoft Visual C++ 2015 Redistributables 64 bit > OK"
	} else {
		"- !!! Visual C++ 2015 64 bit not exist !!!"
		"will try to install automatically"
		Copy-item "\\id-s-file1\ittools\Mandatory\vc_redist.x64.exe" -container -recurse \\$computer\c$\installer\
		Invoke-Command -ComputerName $computer -scriptblock {Start-Process "C:\\installer\\vc_redist.x64.exe" -argumentlist '/q' -wait}
	}
	
	#check skype
	if($cprod.name -like "*skype*") {
		"- Skype > OK"
	} else {
		"- !!! Skype not exist !!!"
		"will try to install skype automatically"
		Copy-item "\\id-s-file1\ittools\Mandatory\\skypesetup.msi" -container -recurse \\$computer\c$\installer\
		#Invoke-Command -ComputerName $computer -scriptblock {msiexec /i "C:\\installer\\skypesetup.msi"}
		Invoke-Command -ComputerName $computer -scriptblock {start-process msiexec -wait -argumentlist '/i C:\\installer\\skypesetup.msi'}
	}

	#check symantec
	if($cprod.name -like "*symantec*") {
		"- Symantec > OK"
	} else {
		"- !!! Symantec not exist !!!"
	}
	
	#check disabled SMBv1
	if($copt.InstallState -eq 2){
		"- SMBv1 disabled > OK"
	}else{
		"- !!! SMBv1 enabled !!!"
		"- This will be enabled by GPO later, don't worry about this"
	}

	#check adaptiva
	if($cserv | Where-Object {$_.name -eq "adaptivaclient"}) {
		"- Adaptiva > OK"
	} else {
		"- !!! Adaptiva service not exist !!!"
	}
	
	#check CCM
	if($cserv | Where-Object {$_.name -eq "cmrcservice"}) {
		"- CCM > OK"
	} else {
		"- !!! CCM service not exist !!!"
	}

	#check vpn for user
	#which user -> get from $user
	$ss = Get-WmiObject -ComputerName $computer -Class Win32_ComputerSystem | Select-Object username
	$user = ($ss.username).split("\")[1]
	#Does phonebook exist
	if(Test-Path \\$computer\c$\users\$user\AppData\Roaming\Microsoft\Network\Connections\Pbk\rasphone.pbk) {
		#if yes is VPN Kompak exist and set to remote.kompak.or.id
		if(Select-String -Pattern "PhoneNumber=remote.kompak.or.id" \\$computer\c$\users\$user\AppData\Roaming\Microsoft\Network\Connections\Pbk\rasphone.pbk){
			"- VPN for $user > OK"
		} else {
			"- !!! VPN for $user not exist !!!"
			"Will try to install VPN Kompak for the current user"
			Copy-item "\\id-s-file1\ittools\Mandatory\\rasphone.pbk" -container -recurse \\$computer\c$\users\$user\AppData\Roaming\Microsoft\Network\Connections\Pbk\
		}
	} else {
		"- !!! VPN for $user not exist !!!"
		"Will try to install VPN Kompak for the current user"
		Copy-item "\\id-s-file1\ittools\Mandatory\\rasphone.pbk" -container -recurse \\$computer\c$\users\$user\AppData\Roaming\Microsoft\Network\Connections\Pbk\
	}
	
	<#OBSOLETE#check logmein - no need
	if($cprod.name -like "*logmein*") {
		"- LogMeIn > OK"
	} else {
		"- !!! LogMeIn not exist !!!"
	}#>
	
	#check fonts (Gotham and Mercury)
	$gotham = get-childitem "\\$computer\C$\Windows\Fonts" -name "*gotham*"
	$mercury = get-childitem "\\$computer\C$\Windows\Fonts" -name "*mercury*"
	if($gotham -and $mercury) {
		"- Fonts > OK"
	} else {
		"- !!! Mercury or Gotham fonts not exist !!!"		
		#copy the folder, fonts and script
		Copy-item "\\id-s-file1\ittools\Mandatory\\AbtJTAFonts" -container -recurse \\$computer\c$\installer\
		Write-Host "Could not install fonts automatically, please do so manually from C:\installer\AbtJTAFonts" -ForegroundColor Yellow
		#do the installation
		#Invoke-Expression "C:\installer\AbtJTAFonts\add-font.ps1 -path C:\installer\AbtJTAFonts"
		#Invoke-Command -ComputerName $computer -scriptblock {start-process "C:\installer\AbtJTAFonts\add-font.ps1 -path C:\installer\AbtJTAFonts" -wait}
	}

	<#OBSOLETE#activate MSoffice
	#$ospp = cscript.exe "\\$computer\c$\program files\microsoft office\office15\ospp.vbs" /dstatus | select-string -pattern: "---LICENSED---"
	if(cscript.exe "\\$computer\c$\program files\microsoft office\office15\ospp.vbs" /dstatus | select-string -pattern: "---LICENSED---") {
		"- Microsoft Office Acivated > OK"
	} else {
		"- !!! MS Office is not activated !!!"
	}
	#running this script remotely return different result than running it locally??? should i user /dstatusall#>
	
	#check office 2016
	if ((test-path "C:\Program Files\Microsoft Office\Office16") -or (test-path "C:\Program Files\Microsoft Office\Office16")){
		"Office 2016 > OK"
	}else{
		"- !!! Office 2016 not exist !!!"
	}
	
	#check BIOS LAN / WLAN auto switching
	if($computermodel -eq "HP Elitebook 840 G3"){
		$shandler = "LAN / WLAN Auto Switching"
		$svalue = "Enabled"
		$check = "gocheck"
	}elseif(($computermodel -eq "HP Elitebook 840 G1") -or ($computermodel -eq "HP Elitebook 820 G1")){
		$shandler = "LAN/WLAN Switching"
		$svalue = "Enable"
		$check = "gocheck"
	}else{
		$check = "nocheck"
	}
	if($check -eq "gocheck"){
		if((Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class hp_biosEnumeration -computername $computer | where-object name -eq $shandler).currentvalue -eq $svalue) {
			"- LAN/WLAN Auto switching in BIOS Enabled > OK"
		} else {
			"- !!! LAN/WLAN Auto switching in BIOS Disabled !!!"
			"Automatically trying to set this to enable"
			(Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class HP_BIOSSettingInterface -computername $computer).SetBIOSSetting($shandler, $svalue)
			if((Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class hp_biosEnumeration -computername $computer | where-object name -eq $shandler).currentvalue -eq $svalue){
				"SUCCESS"
			}else{
				"Failed. Please try manually."
			}
		}
	}else{		
		"Could not check BIOS. Computer model is " + (Get-WmiObject -Class Win32_ComputerSystem -computername $computer).model
	}
	
	#check lan over wifi

	#check chrome
	if((Test-path "\\$computer\C$\Program Files (x86)\Google\Chrome\Application\chrome.exe") -or (Test-path "\\$computer\C$\Program Files\Google\Chrome\Application\chrome.exe")) {
		"- Chrome > OK"
	} else {
		"- !!! Chrome not exist !!!"
		"> will try to install Chrome automatically"
		Copy-item "\\id-s-file1\ittools\Mandatory\\googlechromestandaloneenterprise64.msi" -container -recurse \\$computer\c$\installer\
		#Invoke-Command -ComputerName $computer -scriptblock {msiexec /i "C:\\installer\\googlechromestandaloneenterprise64.msi"}
		Invoke-Command -ComputerName $computer -scriptblock {start-process msiexec -wait -argumentlist '/i C:\\installer\\googlechromestandaloneenterprise64.msi /passive'}
	}
	
	#check silverlight
	if($cprod.name -like "*silverlight*") {
		"- Silverlight > OK"
	} else {
		"- !!! Silverlight not exist !!!"
		"> will try to install silverlight automatically"
		Copy-item "\\id-s-file1\ittools\Mandatory\\silverlight_x64.exe" -container -recurse \\$computer\c$\installer\
		Invoke-Command -ComputerName $computer -scriptblock {Start-Process "C:\\installer\\silverlight_x64.exe" -argumentlist '/q' -wait}
	}
	
	#check bluetooth
	#Get-WmiObject -class Win32_PnPSignedDriver -ComputerName $computer | select devicename | where {$_.devicename -like "*bluetooth*"}
	if($cpnp.devicename -like "*bluetooth device*"){
		"- Bluetooth > OK"
	} else {
		"- !!! Bluetooth not exist !!!"
		Copy-item "\\id-s-file1\ittools\Mandatory\\840G3\\bluetooth.SP74472.exe" -container -recurse \\$computer\c$\installer\
		Write-Host "Could not install Bluetooth automatically, please do so manually from C:\installer" -ForegroundColor Yellow
		#get computer type
		<#if ($computermodel = "HP Elitebook 840 G3"){
			# Check if work directory exists if not create it
			If (Test-Path -Path "\\$computer\c$\SWsetup\SP744732" -PathType Container){
				Write-Host "$workdir already exists" -ForegroundColor Red
			}ELSE{
				#Copy-item "\\id-s-file1\ittools\Mandatory\\840G3\\SP74472" -container -recurse \\$computer\c$\SWsetup\SP74472
				#Copy-item "\\id-s-file1\ittools\Mandatory\\840G3\\bluetooth.SP74472.exe" -container -recurse \\$computer\c$\installer\
				#Copy-item "\\id-s-file1\ittools\Mandatory\\840G3\\SP74472" -container -recurse \\$computer\c$\SWsetup\SP74472
			}
			#Invoke-Command -ComputerName $computer -scriptblock {msiexec /i "C:\\SWsetup\\SP744732\\Intel Bluetooth.msi"}
			#Invoke-Command -ComputerName $computer -scriptblock {start-process msiexec -wait -argumentlist "/i 'C:\\SWsetup\\SP744732\\Intel Bluetooth.msi'"}
			#Invoke-Command -ComputerName $computer -scriptblock {Start-Process "C:\\SWsetup\\SP744732\\setup.exe" -wait}
			Invoke-command -computername $computer -scriptblock {Start-process "C:\\installer\\bluetooth.SP744732.exe /s" -wait}
		}else{
			"Please download and install bluetooth driver for  $computermodel manually"
		}#>
		#final check
		if($cpnp.devicename -like "*bluetooth device*"){
			Write-Host "Blutooth > OK " -ForegroundColor Yellow
		}else{
			Write-Host "Could not install Bluetooth, please do so manually" -ForegroundColor Red
		}
	}
	
	#Reminder to update windows and symantec and GPUPDATE
	"Please also be sure to update Windows and Symantec definition, has correct entry in Asset Management, has asset tag, and run gpupdate."
	"====="
} else {
	"$computer is not pinging. Please check connectivity."
}
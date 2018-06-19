write-host "Multiple computers?"
$readhost = read-host " ( y / n ) "
Switch ($ReadHost) { 
	Y {Write-host "Yes, read from computernames.txt"; $mc=$true} 
	N {Write-Host "No, just 1 computer"; $mc=$false} 
	Default {Write-Host "Default, No, just 1 computer"; $mc=$false} 
}
if ($mc){
	#setting variable computer name	
	#for multiple computers
	$computeri = Get-Content C:\Users\budhi.kurniawan\Desktop\Budhi\Projects\LaptopAssurer\computernames.txt
}else{
	$computeri = read-host -prompt "Input Computer Name"
}

write-host "Automatically fix errors?"
$autofix = read-host " ( y / n ) "
Switch ($autofix) { 
	Y {Write-host "Yes, autofix"; $af=$true} 
	N {Write-Host "No, no autofix"; $af=$false} 
	Default {Write-Host "Default, no autofix"; $af=$false} 
}

write-host "checking computer(s):"
$computeri
#$user = read-host -prompt "Input User Name"
#setting variable installers location
$insloc = read-host -prompt "Input Installer location"
if ($insloc -eq ""){
	$insloc = "\\id-s-file1\ittools\mandatory"
	#$insloc = "\\192.168.62.17\ittools\mandatory"
}

#Functions
Function get-fileassocs ($trees, $asoftw)
{
	$farz = "OK"
	foreach ($tree in $trees) {
		$tree2 = "." + $tree
		$value = Invoke-Command -ComputerName $computer -ScriptBlock {cmd /c assoc $tree2} -ErrorAction Stop
		$value = cmd /c assoc $tree2
		if ($asoftw -eq "7-Zip"){
			$rr = "$asoftw$tree2"
		}elseif($asoftw -eq "Foxit"){
			$rr = "FoxitReader.Document"
		}
		if ($value -ne "$tree2=$rr"){
			$farz = "NG"			
			break
		}		
	}
	return $farz
}

#Start laptopassurer

#loop through the computers
foreach($computer in $computeri){
	write-warning "***** start check of $computer *****"

if(test-connection -computername $computer -count 2 -quiet){
	"====="
	"$computer is pinging"
	"Now checking settings..."

	#get computer model	
	$computermodel = (Get-WmiObject -Class Win32_ComputerSystem -computername $computer).model
	"Computer Model=$computermodel"
	#get OS
	$compos = (gwmi win32_operatingsystem -cn $computer).caption
	"OS=$compos"
	#evaluate if windows 10: if ($compos -like '*Windows 10*') { } else { }
	#getcomputerarchitecture
	$computerarch = (gwmi win32_operatingsystem -cn $computer).osarchitecture
	"Computer Architecture=$computerarch"
	if ($computerarch -eq "64-bit"){
		$86 = ""
	}else{
		$86 = " (86)"
	}
	
	#get computer serial number
	$csn = (get-wmiobject -class win32_bios -computername $computer).serialnumber
	"Serial Number : $csn"
	
	#get computer OU
	$computerou = (([adsisearcher]"(&(name=$computer)(objectClass=computer))").findall().path).split(",")[2]
	"$computerou"
	

	$workdir = "\\$computer\c$\installer\"
	# Check if work directory exists if not create it
	If (Test-Path -Path $workdir -PathType Container){
		Write-Host "$workdir already exists" -ForegroundColor gray
	}ELSE{
		New-Item -Path $workdir  -ItemType directory
	}

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
		write-host "Windows not yet activated" -ForegroundColor Yellow
	}
	
	#Check timezone
	if ($ctime.Caption -like "*Jakarta*") {
		"- Time zone > OK"
	} else {
		write-host "Time Zone incorrect" -ForegroundColor Yellow
		if($af){
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
	}

	#check 7z
	#7-Zip file associations
	$trees = @("001","7z","arj","bz2","bzip2","cab","cpio","deb","dmg","fat","gz","gzip","lha","lzh","lzma","rar","rpm","squashfs","swm","tar","taz","tbz2","tgz","tpz","txz","vhd","wim","xar","xz","z","zip")
	$r7z = get-fileassocs $trees "7-Zip"
	if($cprod.name -like "*7-Zip*") {
		"- 7z installed > OK"
		#checking file association		
		if($r7z -eq "NG"){
			write-host "7z not associated with files properly." -ForegroundColor Yellow			
		}
	} else {
		write-host "- !!! 7z not exist !!!" -foregroundcolor Yellow
		if($af){
			"will try to install 7z automatically"
			Copy-item "$insloc\7z1604-x64.msi" -container -recurse \\$computer\c$\installer\
			Invoke-Command -ComputerName $computer -scriptblock {start-process msiexec -wait -argumentlist '/i C:\\installer\\7z1604-x64.msi /qb'}
			write-host "Please set association with 7z manually." -ForegroundColor Yellow
		}
	}
	
	#check VLC
	if(test-path "\\$computer\c$\Program Files\VideoLAN\VLC\vlc.exe") {
		"- VLC installed > OK"
	} else {
		write-host "VLC not exist !!!" -foregroundcolor Yellow
		if($af){
			"will try to install VLC automatically"
			Copy-item "$insloc\vlc-2.2.5.1-win64.exe" -container -recurse \\$computer\c$\installer\
			Invoke-Command -ComputerName $computer -scriptblock {start-process "C:\\installer\\vlc-2.2.5.1-win64.exe" -argumentlist '/L=1033 /S' -wait}
		}
	}
	
	#check Foxit
	#Foxit file associations
	$trees = @("pdf")
	$rfo = get-fileassocs $trees "Foxit"
	if($cprod.name -like "*Foxit Reader*") {
		"- Foxit > OK"
		#checking file association		
		if($rfo -eq "NG"){
			write-host "Please set association with Foxit manually." -ForegroundColor Yellow			
		}
	} else {
		write-host "- !!! Foxit not exist !!!" -foregroundcolor Yellow
		if ($af){
			"will try to install and associate pdf with Foxit"
			Copy-item "$insloc\\FoxitReader83_enu_Setup.msi" -container -recurse \\$computer\c$\installer\
			#Invoke-Command -ComputerName $computer -scriptblock {msiexec /i "C:\\installer\\skypesetup.msi"}
			Invoke-Command -ComputerName $computer -scriptblock {start-process msiexec -wait -argumentlist '/i C:\\installer\\FoxitReader83_enu_Setup.msi DESKTOP_SHORTCUT="1" MAKEDEFAULT="1" VIEWINBROWSER="1" LAUNCHCHECKDEFAULT="1" AUTO_UPDATE="2" /passive /norestart /qn'}	
		}
	}	
	
	#check disabled SMBv1
	#smb server config - no restart
	if((get-smbserverconfiguration -cimsession $computer).enablesmb1protocol -eq $False){		
		"- SMBv1 disabled > OK"
	}else{		
		if($af){
			write-host "SMB1 Protocol enabled, automatically disabling it." -foregroundcolor Yellow
			Set-SmbServerConfiguration -EnableSMB1Protocol $false -force -cimsession $computer
		}
	}
	#smb enablement - require restart
	<#if($copt.InstallState -eq 2){
		"- SMBv1 disabled > OK"
	}else{
		"- !!! SMBv1 enabled !!!"
		"- Will try to disable this automatically."
		Invoke-Command -ComputerName $Computer {Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol -NoRestart}
		"- SMBv1 disablement will be completed after restart."
	}#>

	#check adaptiva
	if($cserv | Where-Object {$_.name -eq "adaptivaclient"}) {
		"- Adaptiva > OK"
	} else {
		write-host "- !!! Adaptiva service not exist !!!" -foregroundcolor Yellow
	}
	
	#check CCM
	if($cserv | Where-Object {$_.name -eq "cmrcservice"}) {
		"- CCM > OK"
	} else {
		write-host "- !!! CCM service not exist !!!" -foregroundcolor Yellow
	}

	#check vpn for user
	#which user -> get from $user
	$ss = Get-WmiObject -ComputerName $computer -Class Win32_ComputerSystem | Select-Object username
	$user = ($ss.username).split("\")[1]
	#via add-vpnconnection
	Try{
		Add-VpnConnection -cimsession $computer -Name "VPN Kompak" -ServerAddress "remote.kompak.or.id" -EncryptionLevel Required -AuthenticationMethod Eap -EapConfigXmlStream $c -SplitTunneling -tunneltype Automatic -RememberCredential $True -ErrorAction Stop
	}catch{
		"- VPN already exist"
	}finally{
		"- VPN for $user > OK"
	}
	
	#check fonts (Gotham, Mercury, Montserrat)
	$gotham = get-childitem "\\$computer\C$\Windows\Fonts" -name "*gotham*"
	$mercury = get-childitem "\\$computer\C$\Windows\Fonts" -name "*mercury*"
	$montserrat = get-childitem "\\$computer\C$\Windows\Fonts" -name "*montserrat*"
	"Fonts:"
	if($gotham -and $mercury -and $montserrat) {
		"- Fonts > OK"		
	}else{
		write-host "- fonts not exist" -foregroundcolor Yellow
		#if($af){
			if(test-path \\$computer\c$\installer\\AbtJTAFonts){
				Write-Host "please install manually from C:\installer\AbtJTAFonts" -ForegroundColor Yellow
			}else{
				#copy the folder, fonts and script
				Copy-item "$insloc\\AbtJTAFonts" -container -recurse \\$computer\c$\installer\
				Write-Host "please install manually from C:\installer\AbtJTAFonts" -ForegroundColor Yellow
			}
		#}
	}
	
	#check if office 2016 exist	
	if (test-path "\\$computer\c$\Program Files$86\Microsoft Office\Office16"){
		"- Office 2016 Installed > OK"
		#check if it's activated
		if(cscript.exe "\\$computer\c$\program files$86\microsoft office\office16\ospp.vbs" /dstatus | select-string -pattern: "---LICENSED---"){
			"- Office 2016 is activated > OK"
		}else{
			write-host "Office 2016 has not been activated" -ForegroundColor Yellow
		}
	} else {
		write-host "- Office 2016 not exist" -ForegroundColor Yellow
	}
	
	#check if Java 8 exist
	if ($cprod.name -like "*java 8*"){
		"- Java Installed > OK"
	} else {
		"- !!! Java not exist !!!"
		if($af){
			"will try to install Javaautomatically"
			Copy-item "$insloc\\jre-8u141-windows-x64.exe" -container -recurse \\$computer\c$\installer\		
			Copy-item "$insloc\\jre-install-options.cfg" -container -recurse \\$computer\c$\installer\	
			Invoke-Command -ComputerName $computer -scriptblock {Start-Process "C:\\installer\\jre-8u141-windows-x64.exe" -argumentlist 'installcfg="C:\\installer\\jre-install-options.cfg"' -wait}
		}
	}
	
	#check if Flash player exist
	if (test-path "\\$computer\C$\Windows\System32\Macromed\Flash\Flash*.ocx"){
		"- Flash player Installed > OK"
	} else {
		"- !!! Flash player not exist !!!"
		"will try to install automatically"
		Copy-item "$insloc\\install_flash_player_16_plugin.exe" -container -recurse \\$computer\c$\installer\					
		Invoke-Command -ComputerName $computer -scriptblock {Start-Process "C:\\installer\\install_flash_player_16_plugin.exe -install" -wait}
	}
	
	#check BIOS LAN / WLAN auto switching
	if(($computermodel -eq "HP Elitebook 840 G3") -or ($computermodel -eq "HP Elitebook 840 G4")){
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
			write-host "- LAN/WLAN Auto switching in BIOS Disabled" -foregroundcolor Yellow
			#if($af){
				"Automatically trying to set this to enable"
				(Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class HP_BIOSSettingInterface -computername $computer).SetBIOSSetting($shandler, $svalue)
				if((Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class hp_biosEnumeration -computername $computer | where-object name -eq $shandler).currentvalue -eq $svalue){
					"SUCCESS"
				}else{
					write-host "Failed. Please try manually." -foregroundcolor Yellow
				}
			#}
		}
	}else{		
		write-host "Could not check BIOS. Computer model is " + (Get-WmiObject -Class Win32_ComputerSystem -computername $computer).model -foregroundcolor Yellow
	}
	
	#check lan over wifi and IPv4 over IPv6
	set-netipinterface -interfaceAlias Ethernet -addressfamily ipv4 -interfacemetric 5 -cimsession $computer
	set-netipinterface -interfaceAlias Ethernet -addressfamily ipv6 -interfacemetric 15 -cimsession $computer
	set-netipinterface -interfaceAlias Wi-Fi -addressfamily ipv4 -interfacemetric 45 -cimsession $computer
	set-netipinterface -interfaceAlias Wi-Fi -addressfamily ipv6 -interfacemetric 55 -cimsession $computer
	"- set net IP interface LAN over wifi and IPv4 over IPv6 > OK"

	#check chrome
	if((Test-path "\\$computer\C$\Program Files (x86)\Google\Chrome\Application\chrome.exe") -or (Test-path "\\$computer\C$\Program Files\Google\Chrome\Application\chrome.exe")) {
		"- Chrome > OK"
		write-host "Please install Webex plugin from Chrome manually" -foregroundcolor yellow
		#check webex addon
	} else {
		write-host "- !!! Chrome not exist !!!" -foregroundcolor Yellow
		if ($af){
			"> will try to install Chrome automatically"
			Copy-item "$insloc\\googlechromestandaloneenterprise64.msi" -container -recurse \\$computer\c$\installer\
			#Invoke-Command -ComputerName $computer -scriptblock {msiexec /i "C:\\installer\\googlechromestandaloneenterprise64.msi"}
			Invoke-Command -ComputerName $computer -scriptblock {start-process msiexec -wait -argumentlist '/i C:\\installer\\googlechromestandaloneenterprise64.msi /passive'}
			#install webex addon
			write-host "Please install Webex plugin from Chrome manually" -foregroundcolor yellow
		}
	}
	
	#check silverlight
	if($cprod.name -like "*silverlight*") {
		"- Silverlight > OK"
	} else {
		write-host "- !!! Silverlight not exist !!!" -foregroundcolor yellow
		if($af){
			"> will try to install silverlight automatically"
			Copy-item "$insloc\\silverlight_x64.exe" -container -recurse \\$computer\c$\installer\
			Invoke-Command -ComputerName $computer -scriptblock {Start-Process "C:\\installer\\silverlight_x64.exe" -argumentlist '/q' -wait}
		}
	}
	
	#check bluetooth
	#Get-WmiObject -class Win32_PnPSignedDriver -ComputerName $computer | select devicename | where {$_.devicename -like "*bluetooth*"}
	if($cpnp.devicename -like "*bluetooth device*"){
		"- Bluetooth > OK"
	} else {
		write-host "- !!! Bluetooth not exist !!!" -foregroundcolor yellow
		if($af){
			Copy-item "$insloc\\840G3\\bluetooth.SP74472.exe" -container -recurse \\$computer\c$\installer\
			Write-Host "Could not install Bluetooth automatically, please do so manually from C:\installer" -ForegroundColor Yellow
			#final check
			if($cpnp.devicename -like "*bluetooth device*"){
				Write-Host "Blutooth > OK " -ForegroundColor Yellow
			}else{
				Write-Host "Could not install Bluetooth, please do so manually" -ForegroundColor Red
			}
		}
	}
	
	#check symantec
	if($cprod.name -like "*symantec*") {
		"- Symantec > OK"
	} else {
		write-host "- !!! Symantec not exist !!!" -foregroundcolor yellow
		if($af){
			"will try to install automatically"
			Copy-item "$insloc\SymRedistributable.exe" -container -recurse \\$computer\c$\installer\
			Invoke-Command -ComputerName $computer -scriptblock {Start-Process "C:\\installer\\SymRedistributable.exe" -argumentlist '-silent' -wait}
		}
	}
	
	#check webex productivitiy tools
	if($cprod.name -like "*webex*") {
		"- Webex Productivity Tools > OK"
	} else {
		write-host "- !!! Webex Productivity Tools not exist !!!" -foregroundcolor yellow
		if($af){
			"will try to install automatically"
			Copy-item "$insloc\abt-ptools-v31.9.2.65.msi" -container -recurse \\$computer\c$\installer\		
			Invoke-Command -ComputerName $computer -scriptblock {start-process msiexec -wait -argumentlist '/i C:\\installer\\abt-ptools-v31.9.2.65.msi /passive'}	
		}
	}
	
	#disable deep sleep
	#install webex for chrome
	#remove edge shortcut from taskbar
	#default programs: foxit, chrome, 7z
	
	#copy postla
	if(Copy-item "$insloc\postla.ps1" -container -recurse \\$computer\c$\installer\){
		"postla copied"
	}else{
		"could not copy postla or postla already existed"
	}	
	
	#Reminder to update windows and symantec and GPUPDATE
	write-host "Please also be sure to update Windows and Symantec definition, has correct entry in Asset Management, has asset tag, and run gpupdate." -ForegroundColor Yellow
	"===done==="	
	
} else {
	write-host "$computer is not pinging. Please check connectivity." -foregroundcolor yellow
}

	write-warning "***** end check of $computer *****"
}

## TODO:
# Set Chrome as default Browser (Win 10)
# Set default file associations for 7z and MS PowerPoint (Win 10)
# Pin to taskbar: Chrome, Word, Excel, Powerpoint, Outlook, Skype4b (Win 10)
# Hide Cortana and People from taskbar (Win 10)
# Check VPN
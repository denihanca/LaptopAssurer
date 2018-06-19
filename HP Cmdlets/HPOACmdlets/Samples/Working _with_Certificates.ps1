<#********************************************Description********************************************

This script is a sample on how to work with different type of certificates.
You need change your OA connection,Username and Password based on your environment.
The sample includes:
                     How to work with CA certification.
					 How to work with LDAP certificate.
                     How to work with HPSIM certificate.
                     How to work with Remote Support certificate.
                     How to work with OA certificate. 
                     How to work with user certificate.					 
***************************************************************************************************#>

##example 1: How to work with CA certification.
#step 1:Check the CA certificate is installed or not.
$c63=Connect-HPOA -OA 192.168.1.63 -Username "Adminname" -Password "password"    
$rtn=Get-HPOACACertificate $c63 
$caFlag=$false
$caPrintfinger="23:CD:0C:DE:8B:96:66:41:50:AC:69:23:93:EA:4D:5C:3D:0B:E0:xx"  

if($rtn.CaCertificate -eq $null)
{
   Write-Host "No CA certifcate is installed." -ForegroundColor Yellow
}else{
        foreach($CA in $rtn.CaCertificate)
        {
          if($CA.Sha1Fingerprint -eq $caPrintfinger)   
            { 
               Write-Host "The CA certificate is installed. " -ForegroundColor Green
               $caFlag=$true
            }
         }
         if(!$caFlag)
         {
           Write-Host "The CA certificate is not installed." -ForegroundColor Red
         }
}

#Step 2:Install CA certificate by uploading certificate content. 
$cerCA= Get-Content "C:\Users\Administrator\Desktop\CA\Admin.cer" -Raw    
$rc=Add-HPOACertificate $c63 -Type CA -Certificate $cerCA
if($rc -eq $null)
{
  Write-Host "Upload CA certificate success !" -ForegroundColor Green
}
else{
   $rcStatus=$rc.StatusType
   $rcMessage=$rc.StatusMessage
   Write-Host "Upload CA certificate fail ! Status Type:$rcStatus; Status Message:$rcMessage" -ForegroundColor Red
}

#Step 3:Confirm the CA has been installed.Repeat step 1.

#Step 4:Remove installed CA certificate.
$caSHA="CE:32:A1:4A:D3:1F:1D:E8:9E:AE:2B:5F:01:A3:23:BD:4B:A1:B7:xx"
$rc=Remove-HPOACertificate $c63 -Type CA -Certificate $caSHA 
if($rc -eq $null)
{
  Write-Host "Remove CA certificate success !" -ForegroundColor Green
}else{
   $rcStatus=$rc.StatusType
   $rcMessage=$rc.StatusMessage
   Write-Host "Remove CA certificate fail ! Status Type:$rcStatus; Status Message:$rcMessage" -ForegroundColor Red
}

#Step 5:Confirm the CA has been Removed.Repeat step 1.


##example 2: How to work with LDAP certificate.
#step 1:Check the LDAP certificate exists or not.
$rtn=Find-HPOA 192.168.1.63 | Connect-HPOA -Username Adminname -Password password |Get-HPOACertificate -Type LDAP
$rc=$rtn.LDAPCertificate
$ldapFlag=$false
$ldapMD5="53:8B:BA:CA:B9:8F:80:CC:F2:5C:D7:26:E0:80:52:xx"   

if($rc -eq $null)
{
    Write-Host "No LDAP Certificate is installed." -ForegroundColor Yellow
}else{
      foreach($ldapCer in $rc)
      {
        if($ldapCer.MD5Fingerprint  -eq $ldapMD5 )   
         { 
              Write-Host "The LDAP certificate is installed. " -ForegroundColor Green
              $ldapFlag=$true
         }
      }
      if(!$ldapFlag)
      {
         Write-Host "The LDAP certificate is not installed." -ForegroundColor Red
      }
   }

#step 2:Import LDAP certificate by uploading certificate content.
$rc=Add-HPOACertificate $c63 -Type LDAP -Certificate "-----BEGIN CERTIFICATE-----
MIICHzCCAYgCCQDSVPR6qsMZzTANBgkqhkiG9w0BAQQFADBUMRgwFgYDVQQKEw9I
ZXdsZXR0LVBhY2thcmQxHjAcBgNVBAsTFU9uYm9hcmQgQWRtaW5pc3RyYXRvcjEY
MBYGA1UEAxMPT0EtMDAyNDgxQTQ4NjJEMB4XDTA2MDYxNDAwMDEwMloXDTE2MDYx
MTAwMDEwMlowVDEYMBYGA1UEChMPSGV3bGV0dC1QYWNrYXJkMR4wHAYDVQQLExVP
bmJvYXJkIEFkbWluaXN0cmF0b3IxGDAWBgNVBAMTD09BLTAwMjQ4MUE0ODYyRDCB
nzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA37xqnY3GUE4Og4C4jL4fvdttFNPu
bCj1gxy25GOb0MjRn5AUA1Z62IH1lMxDpzat/EKUg22e1gTybTVdzClPlLR0chdK
432dsm32Ig7HJO//3oX8KWVl6QpS7oYaUVB0ppWOs3OHD5RbIU73V/e+GNra9Q9b
E/tczdu/2Vq+3DcCAwEAATANBgkqhkiG9w0BAQQFAAOBgQCXunPKEAASFcXjYXzQ
EO16J3g8j4MnpI0Sl2foWg7nQLhgcI1BjmX5XTddJ+zoawG5y4t+1g8mT/ChNE1w
53fqdY8L77iydMZj3UsJ08zR62I/XlFtT/cgM6asl2fq115BP0gfw8hN1fZPcQ20
6wKTBaV++2vq+NLFy7xlunKDxx==xx
-----END CERTIFICATE-----"            

if($rc -eq $null)
 {
   Write-Host "Success to install  LDAP certificate !" -ForegroundColor Green  
 }else{
        $rcStatus=$rc.StatusType
        $rcMessage=$rc.StatusMessage
        Write-Host " Fail to install LDAP certificate . Status type: $rcStatus; Status message:$rcMessage" -ForegroundColor Red
 }

#*step 2:Import LDAP certificate by downloading certificate.
$rc=Start-HPOACertificateDownload $c63 -Type LDAP -URL "ftp://192.168.1.10/OA_CA/LDAPWestNorth.cer"
if($rc -eq $null)
 {
   Write-Host " Success to download the LDAP certificate!" -ForegroundColor Green  
 }else{
        $rcStatus=$rc.StatusType
        $rcMessage=$rc.StatusMessage
        Write-Host "Fail to download the LDAP certificate. Status type: $rcStatus; Status message:$rcMessage" -ForegroundColor Red
 }

 #step 3:Check installed LDAP certificate.
$rc = Get-HPOALDAPCertificate $c63
$ldapFlag=$false
$ldapMD5="53:8B:BA:CA:B9:8F:80:CC:F2:5C:D7:26:E0:80:52:xx"

if($rc -eq $null)
{
    Write-Host "No LDAP Certificate is installed." -ForegroundColor Yellow
}
else{
      foreach($i in $rc.LDAPCertificate)
      {
        if($i.MD5Fingerprint  -eq $ldapMD5 )   
         { 
              Write-Host "The LDAP certificate is installed. " -ForegroundColor Green
              $ldapFlag=$true
         }
      }
      if(!$ldapFlag)
      {
         Write-Host "The LDAP certificate is not installed." -ForegroundColor Red
      }
   }


 #step 4:Remove installed LDAP certificate.
 $rc=Remove-HPOACertificate $c63 -Type LDAP "53:8B:BA:CA:B9:8F:80:CC:F2:5C:D7:26:E0:80:52:xx" 
 if($rc -eq $null)
{
  Write-Host "Remove LDAP certificate success !" -ForegroundColor Green
}else{
       $rcStatus=$rc.StatusType
       $rcMessage=$rc.StatusMessage
       Write-Host "Remove LDAP certificate fail ! Status Type:$rcStatus; Status Message:$rcMessage" -ForegroundColor Red
}

 #step 5:Check LDAP certificate removed success.Repeat step 1.


##example 3:How to work with HPSIM certificate
#step 1: Check HPSIM certificate
$c63=Connect-HPOA -OA 192.168.1.63 -username Adminname -password password   
$rtn=$c63 | Get-HPOAHPSIMInfo 
$wantedHPSIMCer=@("cer1","cer2","etc..")
$hpsimFlag=$false
if($rtn.TrustedServerCertificate -eq $null)
{
  Write-Host "No HPSIM certificate be installed." -ForegroundColor Yellow
}else{
       foreach($i in $rtn.TrustedServerCertificate)
       {
          if($wantedHPSIMCer -contains $i.CommonName)
            {
              $cerName=$i.CommonName
              Write-Host "The wanted HPSIM certificate `"$cerName`" has been installed" -ForegroundColor Green
            }          
       }
}

#step 2:Import hpsim certificate by hpsim certificate content.
$hpsimCer= Get-Content ".\Desktop\hpsim.cer" -Raw
$rc=Add-HPOACertificate $c63 -Type HPSIM -Certificate $hpsimCer
if($rc -eq $null)
{
  Write-Host "HPSIM certificate is installed success !" -ForegroundColor Green 
}
else{
        $rcStatus=$rc.StatusType
        $rcMessage=$rc.StatusMessage
        Write-Host " Fail to install HPSIM certificate. Status type: $rcStatus; Status message:$rcMessage"   -ForegroundColor Red
}


#*Step 2:Import hpsim certificate by download hpsim certificate. URL is HPSIM server IP.
$rc=Start-HPOACertificateDownload $c63 -Type HPSIM -URL 192.168.1.10   
if($rc -eq $null)
{
  Write-Host "Success to Download HPSIM certificate !" -ForegroundColor Green 
}
else{
        $rcStatus=$rc.StatusType
        $rcMessage=$rc.StatusMessage
        Write-Host " Fail to download HPSIM certificate. Status type: $rcStatus; Status message:$rcMessage"   -ForegroundColor Red
}

#Step 3:Check wanted HPSIM certificate has been installed. Repeat Step 1.

#Step 4:Remove installed HPSIM certificate.
$cerObj= New-Object -TypeName PSobject -Property @{"Connection"=$c63;"Type"="HPSIM";"Certificate"="XXXXXX"}  # "Certificate" is HPSIM certificate CommonName value.
$rc=$cerObj | Remove-HPOACertificate
if($rc -eq $null)
{
  Write-Host "Success to remove HPSIM certificate !" -ForegroundColor Green 
}
else{
        $rcStatus=$rc.StatusType
        $rcMessage=$rc.StatusMessage
        Write-Host " Fail to remove HPSIM certificate. Status type: $rcStatus; Status message:$rcMessage"   -ForegroundColor Red
}

##example 4:How to work with Remote Support certificate
#step 1: Check Remote Support certificate
$c63=Connect-HPOA -OA 192.168.1.63 -username Adminname -password password    
$rtn=$c63 | Get-HPOACertificate  -Type RemoteSupport 
$wantedRemoteCer=@("xxx")  #"Certificate" value is certificate's SubjectCommonName
$remoteFlag=$false
if($rtn.RemoteSupportCertificate -eq $null)   
{
  Write-Host "No HP Remote support certificate be installed." -ForegroundColor Yellow
}else{
       foreach($i in $rtn.RemoteSupportCertificate)
       {
          if($wantedRemoteCer -contains $i.SubjectCommonName)
            {
              $cerName=$i.SubjectCommonName 
              Write-Host "The  Remote support certificate `"$cerName`" has been installed" -ForegroundColor Green
              $remoteFlag=$true
            }          
       }
       else(!$remoteFlag)
       {
         Write-Host "The  Remote support certificate is not installed." -ForegroundColor Red
       }
}


#step 2:Import Remote support server certificate by upload certificate content.
$cer = Get-Content "C:\Users\Administrator\Desktop\CA\RemoteSupport.cer" -Raw 
$cerObj= New-Object -TypeName PSobject -Property @{"Connection"=$c63;"Type"="RemoteSupport";"Certificate"="$cer"}
$rc=$cerObj | Add-HPOACertificate 
if($rc -eq $null)
{
  Write-Host "Success to add Remote support certificate !" -ForegroundColor Green 
}
else{
        $rcStatus=$rc.StatusType
        $rcMessage=$rc.StatusMessage
        Write-Host " Fail to add Remote support certificate. Status type: $rcStatus; Status message:$rcMessage"   -ForegroundColor Red
}

#*step 2:Import Remote support server certificate by downloading certificate.
$rc=Start-HPOACertificateDownload $c63 -Type RemoteSupport -URL "ftp://192.168.1.10/OA_CA/RemoteSupport.cer"
if($rc -eq $null)
{
  Write-Host "Success to add Remote support certificate !" -ForegroundColor Green 
}
else{
        $rcStatus=$rc.StatusType
        $rcMessage=$rc.StatusMessage
        Write-Host " Fail to add Remote support certificate. Status type: $rcStatus; Status message:$rcMessage"   -ForegroundColor Red
}

#step 3:Check installed remote support server certificate. Repeat step 1.

#step 4:Remove remote support server certificate.
$rc=Remove-HPOACertificate $c63 -Type RemoteSupport -Certificate "B1:BC:96:8B:D4:F4:9D:62:2A:A8:9A:81:F2:15:01:52:A4:1D:82:xx"  #Certificate value is Certificate's SHA1 . 
if($rc -eq $null)
{
  Write-Host "Success to Remove Remote support certificate !" -ForegroundColor Green 
}
else{
        $rcStatus=$rc.StatusType
        $rcMessage=$rc.StatusMessage
        Write-Host " Fail to Remove Remote support certificate. Status type: $rcStatus; Status message:$rcMessage"   -ForegroundColor Red
}

###example 5:How to work with OA certificate
##Scenario 1:Selfsigned.
#step 1: find out OA servers need selfsigned certificate.
$conns=Find-HPOA 192.168.1.62-64 | 
% {Add-Member -PassThru -InputObject $_ Username "Administrator"}|
% {Add-Member -PassThru -InputObject $_ Password "Admin"}|
Connect-HPOA

#Step 2:Start OA selfsigned certificate generation.
$cerProperties= New-Object -TypeName PSobject -Property @{"connection"=$conns;"Hostname"="PowershellOA";"Organization"="HP";"State"="CQ";"Country"="CN";"City"="CQ"}  
$cers= $cerProperties | Start-HPOACertificateGeneration -Type SELFSIGNED

foreach($i in $cers)
{
  $okMessage= $i.StatusMessage.Split(".")
  $oaIP=$i.IP
  if($okMessage -contains "Successfully installed new self signed certificate")
      {
        Write-Host " OA:$oaIP success to installed Selfsigned Certificate" -ForegroundColor Green
      }
  else{
        $statusMessage=$i.StatusMessage
        Write-Host " OA:$oaIP  fail to install selfsigned Certificate. Error message :$statusMessage"
      }
}

#Step 3:Check installed OA selfsigned certificate.
$conns=Connect-HPOA -OA 192.168.1.62-64 -Username Administrator -Password Admin
$rc = Get-HPOACertificate $conns -Type OA 
$oaflag=$false
foreach($i in $rc)
 {
     $oaIP=$i.IP
     $scer=$i.OnboardAdministrator
     foreach($s in $scer)
     {
        if($s.CommonName -eq "PowershellOA")
          {
            Write-Host "OA:$oaIP selfsigned certificate has been installed." -ForegroundColor Green 
            $oaflag=$true
          }
     }
     if(!$oaflag)
     {
       Write-Host "OA:$oaIP selfsigned certificate not be found." -ForegroundColor Red
     }
 }

##Scenario 2:REQUEST.
#Step 1:Start OA request certificate generation.
$c63=Connect-HPOA 192.168.1.63 -Username Administrator -Password Admin
$rc=Start-HPOACertificateGeneration $c63 -Type REQUEST -Hostname "WestNorth" -Organization "HP" -City "CQ" -State "CQ" -Country "CN" 
$cerContent=$rc.RequestedCertificate
if($cerContent -eq $null)
{
  Write-Host "Fail to generate OA Request certificate !" -ForegroundColor Red
}
else{
   Write-Host "Success to generate OA certificate. Status type: $cerContent"   -ForegroundColor Green
}

#step 2:Use request certificate content generated in step 1 to be signed by 3rd CA server, getting signed certificate.

#step 3:Import signed certificate by uploading certificate content.
$signedCer=get-content "C:\Users\Administrator\Desktop\CA\WestNorthRequest.cer" -Raw
#Because OA not supports upload signed certificate content by command way, you need to do this on OA web page. 

#*step 3:Import signed certificate by downloading certificate.
$rc= Start-HPOACertificateDownload $c63 -Type OA -URL "ftp://192.168.1.10/OA/WestNorthRequest.cer" 
$rcMessage=$rc.StatusMessage
$okMessage=$rcMessage.Split(".")
if($okMessage -contains "Security Certificate accepted and applied")
  {
     Write-Host "Success to installed requested Certificate" -ForegroundColor Green
   }
else{
     Write-Host "Fail to install requested Certificate. Error message :$rcMessage" -ForegroundColor Red
   }

#Use this example scenario 1, step 3 to check installed requested OA certificate.

##Example 6:How to work with user certificate.
##Root CA and Level-1 CA must be installed then install user CA, making Two-Factor Authentication works.
#Step 1:Install Root CA by uploading certificate content.
$c63=Connect-HPOA 192.168.1.63 Administrator Admin
$rc=Add-HPOACertificate $c63 -Type CA -Certificate "-----BEGIN CERTIFICATE-----
MIIDkTCCAnmgAwIBAgIJAISHNdk58P9qMA0GCSqGSIb3DQEBCwUAMDkxDDAKBgNV
BAMTA2NhMDEUMBIGCgmSJomT8ixkARkWBHRlc3QxEzARBgoJkiaJk/IsZAEZFgNj
b20wHhcNMTQwMzI4MTQ1OTIyWhcNMTkwMzI3MTQ1OTIyWjA5MQwwCgYDVQQDEwNj
YTAxFDASBgoJkiaJk/IsZAEZFgR0ZXN0MRMwEQYKCZImiZPyLGQBGRYDY29tMIIB
IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtP0r7R3Md7krk/p0EnXdYoAa
FBCTsGPloOajbDksSGxJi9/OowrxKx3pFRWxivZ3ZWqPejCmGhFpaRsXX2rjrD/6
nAvQOCm9DJkOPASvZC4YoRZk8J41MdeQIQm1eecSGIuemDNlcd5KxwHhU/lUoOQj
WyIr/GrponpvD6931HLYY5o8+b9dLTYSzOuqSfT4rhiTk8g1ZznjKit6CS1M8fDr
l29ZRBYVf1pXVdQiUEg0IuMvM7biUazoV58B8Q9w1EkU3jxKHzVG5OHoPHX6smcS
1Z1T28oiiO1vneiTGyyRMl8Pm0N19L/fxWTpYrTlGqcjhKBHOA+c2iwE5qiL9QID
AQABo4GbMIGYMB0GA1UdDgQWBBRvpPeveY3R8HlIaFLdvDhGh54hEDBpBgNVHSME
YjBggBRvpPeveY3R8HlIaFLdvDhGh54hEKE9pDswOTEMMAoGA1UEAxMDY2EwMRQw
EgYKCZImiZPyLGQBGRYEdGVzdDETMBEGCgmSJomT8ixkARkWA2NvbYIJAISHNdk5
8P9qMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBABk8ZBSmTx8r1rhL
kZJLHZKndhtOLsF1AIF6TCBsqxCpw0C2XXzMOSg+yGACo90rDg7AMlPUjO4ObcYg
GlhE5m+5I9mjaZhRI+/NaUtTMAj4PfzHkk1WzarYQmJ7wl3hwcmeVoBqbGKWn97E
OVEnqO9ZO33TWXfpoVxcvSsSr/06oz7ZpzqOympQcrjBxA5xz2HMPBbQs0Jobn2Q
STWnnn5gNITG5aK1EvXyMDYnkgpb6nS05QcMYO4cubFCtBtXlVVNYgvx/ZIdOwiQ
EYBGUvHoVMJQUHgnG9AG5YHtRphmhGhZukkWOxV/LPIdC3mhCGp0wJipl5NugCun
f4dOxxx=
-----END CERTIFICATE-----
"

if($rc -eq $null)
{
  Write-Host "Success to upload CA certificate !" -ForegroundColor Green 
}
else{
        $rcStatus=$rc.StatusType
        $rcMessage=$rc.StatusMessage
        Write-Host " Fail to upload certificate. Status type: $rcStatus; Status message:$rcMessage"   -ForegroundColor Red
}

#step 2:Install Level-1 CA by downloading certificate.
$level1CAURL="ftp://192.168.1.10/OA_CA/User_CertificateChain_CA/ca1.cer"
$rc=Start-HPOACertificateDownload $c63 -Type CA -URL $level1CAURL 
if($rc -eq $null)
{
  Write-Host "Success to download CA certificate !" -ForegroundColor Green 
}
else{
        $rcStatus=$rc.StatusType
        $rcMessage=$rc.StatusMessage
        Write-Host " Fail to download certificate. Status type: $rcStatus; Status message:$rcMessage"   -ForegroundColor Red
}

#step 3:Install user CA by uploading certificate.
$userCA= Get-Content "C:\Users\Administrator\Desktop\CA\user1.cer" -Raw
$rc=Add-HPOACertificate $c63 -Type User -Username Administrator -Certificate $userCA
if($rc -eq $null)
{
  Write-Host "Success to upload user certificate !" -ForegroundColor Green 
}
else{
        $rcStatus=$rc.StatusType
        $rcMessage=$rc.StatusMessage
        Write-Host " Fail to upload user certificate. Status type: $rcStatus; Status message:$rcMessage"   -ForegroundColor Red
}

#step 4:Check user certificate.
$rtn = Get-HPOAUser $c63 -Username Administrator
$oaIP=$rtn.IP
$CAflag=$false

if($rtn.Fingerprint -eq $null) 
{
   Write-Host "OA:$oaIP, No user certificate be installed." -ForegroundColor Yellow
}
elseif($rtn.Fingerprint -eq "b6:e4:97:2d:f3:89:d4:5d:4a:8d:04:aa:6a:cd:d5:ab:6b:03:a9:xx")
      {
          Write-Host "Wanted User certificate is installed." -ForegroundColor Green
      }
else{
       Write-Host "Wanted user certificate is not installed." -ForegroundColor Red
    }

#step 5:Remove user certificate
$rc= Remove-HPOAUserCertificate $c63 -Username Administrator   
if($rc -eq $null)
{
  Write-Host "Success to remove user certificate !" -ForegroundColor Green 
}
else{
        $rcStatus=$rc.StatusType
        $rcMessage=$rc.StatusMessage
        Write-Host " Fail to remove user certificate. Status type: $rcStatus; Status message:$rcMessage"   -ForegroundColor Red
}

#step 6:Repeat step 4 to check the certificate has been removed successfully.


#Disconnect the connections.
Disconnect-HPOA -Connection $c63

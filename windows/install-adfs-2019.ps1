
Install-windowsfeature adfs-federation -IncludeManagementTools

Import-Module ADFS

$theDomain="$env:USERDOMAIN"
$userDNSDomain="$env:USERDNSDOMAIN"

# do NOT prompt
#$installationCredential = Get-Credential -Message "Enter credentials of user to perform config"
#$serviceAccountCredential = Get-Credential -Message "Enter credential for federation service acct"

# instead, construct PSCredential
$password = ConvertTo-SecureString -string "ThisIsMyP4ss!" -AsPlainText -force
$installationCredential = New-Object System.Management.Automation.PSCredential("$theDomain\Administrator",$password)
$serviceAccountCredential = New-Object System.Management.Automation.PSCredential("$theDomain\adfs1",$password)

$leafThumbprint=(get-ChildItem -Path 'Cert:\LocalMachine\My' | where-object { $_.Subject -like 'CN=win2k19-adfs1*' }).Thumbprint
write-host "leafThumbprint is $leafThumbprint"

# going to use our cert for: service, token-decrypt, and token-signing
# otherwise we would need to get the generated tokens and add to 'Root' store
#      get-adfscertificate -certificateType token-signing
#      get-adfscertificate -certificateType token-decrypting
Install-AdfsFarm `
-CertificateThumbprint "$leafThumbprint" `
-SigningCertificateThumbprint "$leafThumbprint" `
-DecryptionCertificateThumbprint "$leafThumbprint" `
-Credential $installationCredential `
-FederationServiceDisplayName "myadfs.$userDNSDomain" `
-FederationServiceName "win2k19-adfs1.$userDNSDomain" `
-ServiceAccountCredential $serviceAccountCredential `
-OverwriteConfiguration `
-Confirm $false

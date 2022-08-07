
# need to load CA certificate into local trusted store
# and adfs certs into personal

Install-windowsfeature adfs-federation -IncludeManagementTools

Import-Module ADFS

$installCreds = Get-Credential -Message "Enter credentials of user to perform config"

$svcCreds = Get-Credential -Message "Enter credential for federation service acct"

Install-AdfsFarm `
-CertificateThumbprint: "xyz" `
-Credential:$installationCredential `
-FederationServiceDisplayName:"adfs.fabian.lee" `
-FederationServiceName:"my win2k19-adfs1.fabian.lee" `
-ServiceAccountCredential:$serviceAccountCredential

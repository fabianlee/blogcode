# Creates ADFS 2019 Application Group for OAuth2 Client and Resource Server
#
# based on: https://github.com/mikefoley/ADFS-cmdlets/blob/master/GitHub-ADFS-Add-App-Group.ps1
#
# 'ClientRoleIdentifier' name of ADFS application group
# 'redirectURL' redirection back to app after authorization
param([String]$ClientRoleIdentifier="AppServer-ADFS",$redirectURL="http://localhost:8080/login/oauth2/code/adfs")

# 'ClientRoleIdentifier' name of your application group
# 'redirectURL' valid URL for redirection after authorization

if (get-adfsapplicationgroup -Name $ClientRoleIdentifier) {
  write-host "SKIP New-AdfsApplicationGroup '$ClientRoleIdentifier'"
}else {	
  # Create the new Application Group in ADFS
  New-AdfsApplicationGroup -Name $ClientRoleIdentifier -ApplicationGroupIdentifier $ClientRoleIdentifier
}

#Create the ADFS Server Application and generate the client secret.
$ADFSApp = Get-AdfsServerApplication -Name "$ClientRoleIdentifier - Server app"
if ($ADFSApp) {
  write-host "SKIP Add-AdfsServerApplication '$ClientRoleIdentifier - Server app'"
  $identifier = $ADFSApp.identifier
}else {	
  # Creates a new GUID for use by the application group
  $identifier = (New-Guid).Guid
  $ADFSApp = Add-AdfsServerApplication -Name "$ClientRoleIdentifier - Server app" -ApplicationGroupIdentifier $ClientRoleIdentifier -RedirectUri $redirectURL  -Identifier $identifier -GenerateClientSecret
}  
write-host "client_id = $identifier"

if (Get-AdfsWebApiApplication -ApplicationGroupIdentifier $ClientRoleIdentifier) {
	write-host "SKIP Add-AdfsWebApiApplication '$ClientRoleIdentifier'"
}else {
  #Create the ADFS Web API application and configure the policy name it should use
  Add-AdfsWebApiApplication -ApplicationGroupIdentifier $ClientRoleIdentifier  -Name "App Web API" -Identifier $identifier -AccessControlPolicyName "Permit everyone"
}  

# allow scope to be used in claims output (not necessary for our claim rules)
#Set-AdfsClaimDescription -ShortName scp -TargetShortName scp -IsAccepted $false -IsOffered $true

# application specific scopes
if (!(Get-AdfsScopeDescription -name api_delete)) {
  Add-AdfsScopeDescription -name api_delete -description "make DELETE calls from API"
}  

#Grant the ADFS Application the allatclaims and openid permissions
if ( (Get-AdfsApplicationPermission -ClientRoleIdentifier $identifier) -and (Get-AdfsApplicationPermission -ServerRoleIdentifier $identifier) ) {
  write-host "SKIP found Get-AdfsApplicationPermission for both client/server identifier '$identifier'"
  Set-AdfsApplicationPermission -TargetClientRoleIdentifier $identifier -TargetServerRoleIdentifier $identifier -ScopeNames @('allatclaims', 'openid', 'api_delete')
}else {
  Grant-AdfsApplicationPermission -ClientRoleIdentifier $identifier -ServerRoleIdentifier $identifier -ScopeNames @('allatclaims', 'openid', 'api_delete')
}

$transformrule = @"
@RuleTemplate = "LdapClaims"
@RuleName = "AD User properties and Groups"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]
 => issue(store = "Active Directory", types = ("given_name", "email", "family_name", "http://schemas.xmlsoap.org/claims/Group"), query = ";givenName,mail,sn,tokenGroups;{0}", param = c.Value);

@RuleTemplate = "MapClaims"
@RuleName = "Populate Roles"
c:[Type == "http://schemas.microsoft.com/identity/claims/scope"]
 => issue(Type = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role", Value = c.Value, Issuer = c.Issuer, ValueType = c.ValueType, OriginalIssuer = c.OriginalIssuer);
"@

# Write out the tranform rules file
$transformrule |Out-File -FilePath .\issueancetransformrules.tmp -force -Encoding ascii
$relativePath = Get-Item .\issueancetransformrules.tmp

# Name the Web API Application and define its Issuance Transform Rules using an external file. 
if (Get-AdfsWebApiApplication -Name "$ClientRoleIdentifier - Web API") {
  write-host "SKIP Add-AdfsWebApiApplication -Name '$ClientRoleIdentifier - Web API'"
  Add-AdfsWebApiApplication -Name "$ClientRoleIdentifier - Web API" -TargetIdentifier $identifier -IssuanceTransformRulesFile $relativePath
}else {
  Set-AdfsWebApiApplication -Name "$ClientRoleIdentifier - Web API" -TargetIdentifier $identifier -IssuanceTransformRulesFile $relativePath  
} 
Remove-Item $relativePath

Write-Host ""
$openidurl = (Get-AdfsEndpoint -addresspath "/adfs/.well-known/openid-configuration")
Write-Host "OpenID URL: " $openidurl.FullUrl.OriginalString
Write-Host "client_id: $identifier"
if ([string]::IsNullOrEmpty($ADFSApp.ClientSecret)) {
  Write-Host "<cannot fetch, recreate if necessary>"
}else {
  Write-Host -ForegroundColor Yellow "client_secret: "$($ADFSApp.ClientSecret)
}  


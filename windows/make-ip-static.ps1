#
# Sets IP address to static
#
# https://adamtheautomator.com/powershell-get-ip-address/
# https://docs.microsoft.com/en-us/powershell/module/nettcpip/set-netipaddress?view=windowsserver2022-ps
# https://techexpert.tips/powershell/powershell-configure-static-ip-address/


# retrieve network information from what may be dynamically assigned IP
# if not static IP, then PrefixOrigin=Dhcp SuffixOrigin=Dhcp
$interfaceIndex=(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet).InterfaceIndex
$prefixLen=(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet).PrefixLength
$interfaceIndexAlternate=(get-netadapter).InterfaceIndex
$ipAddress=(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet).IPAddress
write-host "The interface index $interfaceIndex/$interfaceIndexAlternate has IP address of $ipAddress"

$gateway=(Get-NetIPConfiguration | select-object -first 1).IPv4DefaultGateway.NextHop
write-host "default gateway is $gateway"


$prefixOrigin=(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet).PrefixOrigin
if ($prefixOrigin -eq "dhcp") {

  # make IP address static
  # must remove first, then add new
  Remove-NetIPAddress -InterfaceIndex $interfaceIndex -Confirm:$false
  New-NetIPAddress -IPAddress $ipAddress -DefaultGateway $gateway -PrefixLength $prefixLen -InterfaceIndex $interfaceIndex
  
  write-host "===NEW INFO======================================"
  Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet

}else {
  write-host "SKIP prefix origin was not dhcp, it was $prefixOrigin so not going to make any changes"
}



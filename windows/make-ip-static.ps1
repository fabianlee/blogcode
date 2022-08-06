
# https://adamtheautomator.com/powershell-get-ip-address/


# retrieve network information from what may be dynamically assigned IP
# if not static IP, then PrefixOrigin=Dhcp SuffixOrigin=Dhcp
interfaceIndex=(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet).InterfaceIndex
prefixLen=(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet).PrefixLength
interfaceIndexAlternate=(get-netadapter).InterfaceIndex
ipAddress=(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet).IPAddress
write-host "The interface index $interfaceIndex/$interfaceIndexAlternate has IP address of $ipAddress"

gateway=(Get-NetIPOConfiguration | select-object -first 1).IPv4DefaultGateway.NextHop
write-host "default gateway is $gateway"

# make IP address static
New-NetIPAddress –IPAddress $ipAddress -DefaultGateway $gateway -PrefixLength $prefixLen -InterfaceIndex $interfaceIndex

write-host "===NEW INFO======================================"
Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet

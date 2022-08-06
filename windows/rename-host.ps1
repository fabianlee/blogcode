param([String]$newname = "win2k19-dc1")

rename-computer -NewName $newname
write-output "name changed to $newname, going to reboot in 3 seconds..."
start-sleep -seconds 3

restart-computer

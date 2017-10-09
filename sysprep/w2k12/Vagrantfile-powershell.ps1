
# for linked clones
Vagrant.require_version ">= 1.8"

vmname = 'clone1'
boxname = 'w2k12base-sysprep-ready'
staticIP = '192.168.1.46'
netbiosName = 'contoso'
domainFQDN = 'contoso.com'

Vagrant.configure(2) do |config|
  config.vm.hostname = "#{vmname}"
  config.vm.box = "#{boxname}"

  # must have for Windows to specify OS type
  config.vm.guest = :windows

  config.vm.network "public_network", ip: "#{staticIP}", bridge: "eth0"

  # winrm | ssh
  config.vm.communicator = "winrm"
  #config.ssh.username = "vagrant"
  #config.ssh.password = "vagrant"
  config.winrm.username = "vagrant"
  config.winrm.password = "vagrant"
  config.ssh.insert_key = false

  config.vm.synced_folder "/home/fabian/Documents", 'c:\users\Administrator\Documents2'

  # put powershell files unto guest and then execute
  config.vm.provision "file", source: "test.ps1", destination: 'c:\users\public\Documents\test.ps1'
  config.vm.provision "file", source: "MakeDomainController.ps1", destination: 'c:\users\public\Documents'
  config.vm.provision "shell", path: "test.ps1", privileged: true, args: "'1' '2'"

  # virtualbox provider
  config.vm.provider "virtualbox" do |v|
    v.name = "#{vmname}"
    v.gui = true
    # use linked clone for faster spinup
    v.linked_clone = true
    v.customize ["modifyvm", :id, "--memory","1024" ]
    v.customize ["modifyvm", :id, "--cpus","1" ]
    # dynamically set properties that can be fetched inside guestOS
    v.customize ["guestproperty", "set", :id, "myid", :id ]
    v.customize ["guestproperty", "set", :id, "myname", "#{vmname}" ]
  end

end



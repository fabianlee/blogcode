locals { 
  params = [ "a", "b", "c"] 
  params_for_inline_command = join(" ",local.params)
}

# for local ssh connection
variable user { default="" }
variable password { default="" }

resource "null_resource" "test" {

  # local ssh connection, make sure to pass variables 'user' andd 'password' on cli
  # terraform apply -var user=$USER -var password=xxxxxxx
  connection { 
    type="ssh"
    agent="false"
    host="localhost"
    user=var.user
    password=var.password
  }

  provisioner "file" {
    destination = "/tmp/script.sh"
    content = templatefile( 
      "${path.module}/script.sh.tpl", 
      { 
        "params": local.params
        "params_for_inline_command" : local.params_for_inline_command 
      } 
    ) 
  }

}

output "run_this_script" {
  value="/bin/bash /tmp/script.sh"
}


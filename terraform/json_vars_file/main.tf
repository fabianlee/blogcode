#
# blog: https://fabianlee.org/2021/09/24/terraform-using-json-files-as-input-variables-and-local-variables/
#

locals {
  # can validate with: jq . values-local.json
  local_data = jsondecode(file("${path.module}/local-values.json"))

  # array of just keys from set
  my_map_keys = [ for k,v in local.local_data.mylocal_map: k ]

  # array of just values from set
  my_map_values = [ for k,v in local.local_data.mylocal_map: v ]

  # array of just specific attribute value from set
  my_map_values_url = [ for k,v in local.local_data.mylocal_map: v.url ]

  # set where we swap the key to be the url
  my_map_values_url_to_name = { for k,v in local.local_data.mylocal_map: v.url=>v.name }
}

# declare input variables and their default value
variable a { default="n/a" }
variable strlist { default=[] }
variable vms {}

# show simple variable
output "show_var_a" {
  value = var.a
}
# show str list
output "show_var_strlist" {
  value = var.strlist
}



output "show_mylocal" {
  value = local.local_data.mylocal
}
output "show_my_map_keys" {
  value = local.my_map_keys
}
output "show_my_map_values" {
  value = local.my_map_values
}
output "show_my_map_values_url" {
  value = local.my_map_values_url
}
output "show_my_map_values_url_to_name" {
  value = local.my_map_values_url_to_name
}

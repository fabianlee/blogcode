#
# blog: 
#

locals {
  file_data_static = [
    { name="foo3", content="this is foo3" },
    { name="foo4", content="this is foo4" }
  ]

  file_data_ext_yaml = yamldecode(file("${path.module}/external.yaml"))
  #file_data_ext_yaml = fileexists("${path.module}/external.yaml") ? yamldecode(file("${path.module}/external.yaml")):{ files= [] }

  file_data_merge = concat( local.file_data_static, local.file_data_ext_yaml.files )
}

#resource "local_file" "foo_test" {
#  for_each = { for entry in local.file_data : entry.name=>entry }
#  content  = each.value.content
#  filename = "${path.module}/${each.value.name}.txt"
#}


resource "local_file" "foo" {
  #for_each = { for entry in local.file_data_ext_yaml.files : entry.name=>entry }
  for_each = { for entry in local.file_data_merge : entry.name=>entry }
  content  = each.value.content
  filename = "${path.module}/${each.value.name}.txt"
}

output "show_ext_yaml_files" {
  value = local.file_data_ext_yaml.files
}

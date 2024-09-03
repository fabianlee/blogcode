#
# blog: https://fabianlee.org/2024/09/01/terraform-external-yaml-file-as-a-contribution-model-for-outside-teams/
#

locals {
  file_data_static = [
    { name="foo1", content="this is foo1" },
    { name="foo2", content="this is foo2" }
  ]

  #file_data_ext_yaml = yamldecode(file("${path.module}/external.yaml"))
  file_data_ext_yaml = fileexists("${path.module}/external.yaml") ? yamldecode(file("${path.module}/external.yaml")):{ files= [] }

  file_data_merge = concat( local.file_data_static, local.file_data_ext_yaml.files )
}

# if hard-coding resources
#resource "local_file" "foo_test" {
#  for_each = { for entry in local.file_data : entry.name=>entry }
#  content  = each.value.content
#  filename = "${path.module}/${each.value.name}.txt"
#}

# for data-driven resources
resource "local_file" "foo" {
  #for_each = { for entry in local.file_data_ext_yaml.files : entry.name=>entry }
  for_each = { for entry in local.file_data_merge : entry.name=>entry }
  content  = each.value.content
  filename = "${path.module}/${each.value.name}.txt"
}

output "show_data" {
  value = local.file_data_merge
  #value = flatten([for file in local.file_data_merge: file.name ])
}

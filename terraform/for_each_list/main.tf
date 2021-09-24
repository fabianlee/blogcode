#
# blog: https://fabianlee.org/2021/09/24/terraform-converting-ordered-lists-to-sets-to-avoid-errors-with-for_each/
#

locals {
  my_set = {
    "a" = { "id":"a", "name":"first", },
    "b" = { "id":"b", "name":"second" },
    "c" = { "id":"c", "name":"third" }
  }
  my_list = [
    { "id":"a", "name":"first" },
    { "id":"b", "name":"second" },
    { "id":"c", "name":"third" }
  ]
  str_list = [ "a","b","c" ]
}

resource "null_resource" "show_set" {
  for_each = local.my_set
  provisioner "local-exec" {
    command = "echo my_set: the name for ${each.key} is ${each.value.name}"
  }
}

resource "null_resource" "show_str_list" {
  # convert string list to set
  for_each = toset( local.str_list )
  provisioner "local-exec" {
    command = "echo str_list: the value is ${each.key}"
  }
}

resource "null_resource" "show_list" {
  # convert ordered list to set
  for_each = { for entry in local.my_list: entry.id=>entry }
  provisioner "local-exec" {
    command = "echo my_list for_each: the name for ${each.value.id} is ${each.value.name}"
  }
}

resource "null_resource" "show_list_with_count" {
  count = length(local.my_list)
  provisioner "local-exec" {
    command = "echo my_list count: the name for ${local.my_list[count.index].id} is ${local.my_list[count.index].name}"
  }
}


#
# example of pulling external map
#

locals {
  datacenter_base_map = {
    usne1 = { name="US northeast1",resources=99 },
    usw1 = { name="US west1",resources=32 }
  }

  datacenter_ext_yaml = fileexists("${path.module}/external-dc.yaml") ? yamldecode(file("${path.module}/external-dc.yaml")):{ datacenters={} }

  datacenter_data_merge = merge( local.datacenter_base_map, local.datacenter_ext_yaml.datacenters )
}

# for data-driven resources
resource "local_file" "dc" {
  for_each = local.datacenter_data_merge
  content  = "${each.value.name} with resources ${each.value.resources}"
  filename = "${path.module}/${each.key}.txt"
}

output "show_data_datacenter" {
  value = local.datacenter_data_merge
}

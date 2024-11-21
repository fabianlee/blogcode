#
# blog: 
#

locals {
  my_projects_list_of_obj = [
    {
      id="proj1",
      projects=[
        { project_id="proja" },
        { project_id="projb" },
      ]
    },
    {
      id="proj2",
      projects=[
        { project_id="projc" }
      ]
    },
    {
      id="proj3",
      projects=[
      ]
    }
  ]

  my_projects_simple_list = [ "proja","projb","projc" ]

}

output flatten_list_of_obj_to_list {
  value = flatten([ for cp in local.my_projects_list_of_obj :
    [ 
    for p_obj in cp.projects: [ p_obj.project_id ]
    ]
  ])
}
output flatten_list_of_obj_to_list_of_map {
  value = flatten([ for cp in local.my_projects_list_of_obj :
    [ 
    for p_obj in cp.projects: { "proj"=p_obj.project_id }
    ]
  ])
}
output flatten_list_of_obj_to_list_then_make_single_map {
  value = { for v in 
    flatten([ for cp in local.my_projects_list_of_obj :
      [ 
      for p_obj in cp.projects: [ p_obj.project_id ]
      ]
    ]) : "${v}"=>"" }
}


output simple_list_to_map {
  value = { for v in local.my_projects_simple_list: "${v}"=>"" }
}

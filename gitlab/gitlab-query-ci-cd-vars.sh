#!/bin/bash
#
# Example showing how GitLab CI/CD variables can be queried at the project and group level using REST API
# and then how list of all inherited variables can be queried using GraphQL
#

[[ -n "$GITLAB_PAT" ]] || { echo "ERROR need to define GITLAB_PAT"; exit 1; }

project_path="$1"
[[ -n "$project_path" ]] || { echo "ERROR need to pass full gitlab project path as param"; exit 1; }

jq_bin=$(which jq)
[[ -n "$jq_bin" ]] || { echo "ERROR need jq installed"; exit 2; }

GITLAB_HOST="gitlab.com"

project_path_encoded=$(echo -n "$project_path" | jq -sRr @uri)

project_json=$(curl -s -XGET -H "Content-Type: application/json" --header "PRIVATE-TOKEN: $GITLAB_PAT" "https://$GITLAB_HOST/api/v4/projects/$project_path_encoded")

project_id=$(echo "$project_json" | jq -r '.id')
group_id=$(echo "$project_json" | jq -r 'select(.namespace.kind == "group") | .namespace.id')
# the project details have only the immediate parent group, always single item and not array
group_path=$(echo "$project_json" | jq -r 'select(.namespace.kind == "group") | .namespace.full_path')
#project_path_with_ns=$( echo "$project_json" | jq -r 'select(.namespace.kind == "group") | .path_with_namespace')

echo "project_id=$project_id"
REST_URL="https://$GITLAB_HOST/api/v4/projects/$project_id/variables"
rest_response=$(curl --silent --header "PRIVATE-TOKEN: $GITLAB_PAT" "$REST_URL")
echo "=== PROJECT LEVEL CI/CD variables ($project_path = $project_id)"
echo "$rest_response" | jq '.[] | [.key,.value] | @csv' -r | sort
echo ""
echo ""

#
# Try pulling immediate group level variables using REST API
# this will fail if user does not have ownership of group
#
if [[ "$group_id" == "null" ]]; then
  echo "No group id found for this gitlab project"
else
  echo "group_id=$group_id"
  curl --silent --write-out "HTTPSTATUS:%{http_code}" \
      --header "PRIVATE-TOKEN: $GITLAB_PAT" \
      "https://$GITLAB_HOST/api/v4/groups/$group_id" | jq . #-r 'select(.namespace.kind == "group") | .namespace.full_path'

  # Attempt REST API call to retrieve group variables
  REST_URL="https://$GITLAB_HOST/api/v4/groups/$group_id/variables"
  rest_response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" \
      --header "PRIVATE-TOKEN: $GITLAB_PAT" \
      "$REST_URL")
  
  http_status=$(echo "$rest_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
  rest_body=$(echo "$rest_response" | sed -e 's/HTTPSTATUS:.*//')
  if [[ $http_status -eq 200 && $(echo "$rest_body" | wc -c) -lt 4 ]]; then
    echo "There are no immediate group level CI/CD variables"
  else
    echo ""
    echo "=== PARENT GROUP CI/CD variables via REST API ($group_path = $group_id)"
    echo "$rest_body" | jq .
  fi
  
  # Check for Permission Errors when retrieving group vars
  # you may not have ownership of group, which means this call cannot pull the group variables
  if [ "$http_status" -eq 200 ]; then
      echo "Success: Retrieved group CI/CD variables via REST API."
  elif [ "$http_status" -eq 403 ] || [ "$http_status" -eq 401 ]; then
      echo "Permission denied when trying to retrieve group CI/CD variables (HTTP $http_status). The GITLAB_PAT use probably does not have group level ownership..."
  else
      echo "REST API failed with status $http_status."
  fi

fi


#
# Pull all inherited group/instance level variables using GraphQL
# this has the ability to show all the inherited variables (group->group->instance)
# however, it cannot pull their values (because this would violate the intended permissions)
#
GRAPHQL_URL="https://$GITLAB_HOST/api/graphql"
GRAPHQL_QUERY="query {
  project(fullPath: \"$project_path\") {
    inheritedCiVariables {
      nodes {
        key
        variableType
        environmentScope
        protected
        groupName
      }
    }
    ciVariables {
      nodes {
        key
      }
    }
  }
}"

gql_response=$(curl --silent --header "Authorization: Bearer $GITLAB_PAT" \
     --header "Content-Type: application/json" \
     --data "{\"query\": $(echo "$GRAPHQL_QUERY" | jq -aRs .)}" \
     "$GRAPHQL_URL")

echo "=== INHERITED CI/CD variables via GraphQL ($project_path = $project_id)"
if echo "$gql_response" | jq -e '.data.project' > /dev/null; then
    echo "Success: Retrieved via GraphQL."
    echo "$gql_response"  | jq '.data.project.inheritedCiVariables.nodes'
else
    echo "Error: Could not retrieve variables from either API."
    echo "$gql_response" | jq .
fi


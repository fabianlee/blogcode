#!/bin/bash
#
# Check full health of: deployments, daemonset, pods
#
# prerequisite: requires 'jq' utility for parsing kubectl json
#


function check_health_of_kind() {
  kind="${1,,}" # force lowercase
  ns="$2"

  # if no namespace specified, scope is all namespaces
  [ -z "$ns" ] && ns_flag="-A" || ns_flag="-n $ns"

  if [[ "$kind" == @(deploy|deployment|deployments) ]]; then
    jq_format_string='.items[] | [.metadata.namespace,.metadata.name,(.status.replicas // 0),(.status.readyReplicas // 0),(.status.unavailableReplicas // 0)] |@csv'
  elif [[ "$kind" == @(ds|daemonset) ]]; then
    jq_format_string='.items[] | [.metadata.namespace,.metadata.name,(.status.desiredNumberScheduled // 0),(.status.numberReady // 0),(.status.numberUnavailable // 0)] |@csv'
  fi

  # pod health can be checked directly
  if [[ "$kind" == @(pod|pods) ]]; then
    pods_unhealthy=$(kubectl get pods $ns_flag -o custom-columns=NAMESPACE:metadata.namespace,POD:metadata.name,READY:status.containerStatuses[*].ready,REASON:status.containerStatuses[*].state.terminated.reason --no-headers | grep false | grep -v "Completed")
    if [[ -n "$pods_unhealthy" ]]; then
      echo $pods_unhealthy
      echo "WARN above pods are not healthy in ns scope: $ns_flag"
    else
      echo "OK all pods healthy in ns scope: $ns_flag"
    fi
  else

    # daemonset and deployment required line-by-line inspection 
    IFS=$'\n'
    lines_output=$( kubectl get $kind $name $ns_flag -o=json | jq "$jq_format_string" -r | tr -d '"' | sed -e '/^$/d' )
    any_unhealthy=0
    for line in $lines_output; do
      if echo "$line" | grep -Pq '(\d+),\1,' ; then
        true
      else
        echo "UNHEALTHY: $line"
        any_unhealthy=1
      fi
    done
    [[ "$any_unhealthy" -eq 0 ]] && echo "OK all $kind healthy in ns scope: $ns_flag"

  fi
}

############### main ####################

# prerequisite utilities
bin=$(which jq)
[[ -z "$bin" ]] && { echo "ERROR need to install jq utility, 'sudo apt install jq -y'"; exit 3; }
bin=$(which kubectl)
[[ -z "$bin" ]] && { echo "ERROR need to install kubectl utility, https://kubernetes.io/docs/tasks/tools/"; exit 3; }

# smoke test of kubectl
kubectl get pods >/dev/null 2>&1
[[ $? -ne 0 ]] && { echo "ERROR could not use kubectl for simple 'kubectl get pods', check your KUBECONFIG and permissions to cluster"; exit 3; }

# check health
echo ""
echo "==POD HEALTH=="
check_health_of_kind pod default

echo ""
echo "==DEPLOYMENT HEALTH=="
check_health_of_kind deployments

echo ""
echo "==DAEMONSET HEALTH=="
check_health_of_kind ds

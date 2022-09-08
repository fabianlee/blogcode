#!/bin/bash
#
# Deploys Keycloak as a Daemonset in kubernetes cluster

# Starts by deploying manifest from KeyCloak QuickStart
# Then augments with volume mount of files and lifecycle hook that bootstraps at startup

# create configmap that holds file content
kubectl delete configmap keycloak-configmap
kubectl create configmap keycloak-configmap --from-file=poststart.sh --from-file=myclient.exported.json

# either pull quickstart manifest remotely OR use the one I copied down locally
#curl -s https://raw.githubusercontent.com/keycloak/keycloak-quickstarts/latest/kubernetes-examples/keycloak.yaml | sed 's/type: LoadBalancer/type: ClusterIP/' | kubectl apply -f -
cat keycloak.yaml | sed 's/type: LoadBalancer/type: ClusterIP/' | kubectl apply -f -

echo "sleeping 3 seconds, then going to apply patch for volume bindings..."
sleep 3
kubectl patch deployment keycloak --type strategic --patch-file keycloak-patch.yaml

# show OAuth2 client_id and client_secret
# kubectl exec -it deployment/keycloak -n default -c keycloak -- cat /tmp/keycloak.properties

# restart of deployment
# kubectl rollout restart deployment/keycloak -n default

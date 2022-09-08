# create configmap that holds file content
kubectl delete configmap keycloak-configmap
kubectl create configmap keycloak-configmap --from-file=poststart.sh --from-file=myclient.exported.json

# either pull quickstart manifest remotely OR use the one I copied down locally
#curl -s https://raw.githubusercontent.com/keycloak/keycloak-quickstarts/latest/kubernetes-examples/keycloak.yaml | sed 's/type: LoadBalancer/type: ClusterIP/' | kubectl apply -f -
cat keycloak.yaml | sed 's/type: LoadBalancer/type: ClusterIP/' | kubectl apply -f -

echo "sleeping 3 seconds, then going to apply patch for volume bindings..."
sleep 3
kubectl patch deployment keycloak --type strategic --patch-file keycloak-patch.yaml

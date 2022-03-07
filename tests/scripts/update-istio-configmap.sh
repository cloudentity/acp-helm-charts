#!/bin/bash

set -e

ISTIO_AUTH_APP="${ISTIO_AUTH_APP:-istio-authoriszer}"
ISTIO_AUTH_APP_NAMESPACE="${ISTIO_NAMESPACE:-istio-authorizer}"
ISTIO_NAMESPACE="${ISTIO_NAMESPACE:-istio-system}"

EXTENSION_CONFIG_LOCATION="tests/config/istio-extension-providers-config.yaml"
WORKDIR="tests/config/tmp"

# Prepare configuration
yq eval --inplace ".extensionProviders.[] |= select(.name == \"acp-authorizer\").envoyExtAuthzGrpc.service |= \"$ISTIO_AUTH_APP.$ISTIO_AUTH_APP_NAMESPACE.svc.cluster.local\"" $EXTENSION_CONFIG_LOCATION

# Fetch current configmap
mkdir -p $WORKDIR
kubectl get configmap istio -n $ISTIO_NAMESPACE -o yaml >$WORKDIR/istio-configmap.yaml

# Update configmap
mesh_config=$(yq eval-all '.data.mesh' $WORKDIR/istio-configmap.yaml | yq eval-all '. as $item ireduce ({}; . * $item )' - $EXTENSION_CONFIG_LOCATION)
data=$mesh_config yq eval-all ".data.mesh = strenv(data)" $WORKDIR/istio-configmap.yaml >$WORKDIR/istio-configmap-new.yaml
kubectl apply -f $WORKDIR/istio-configmap-new.yaml

# Apply changes to istio
kubectl rollout restart deployment/istiod -n $ISTIO_NAMESPACE

#!/bin/bash

set -e

ISTIO_NAMESPACE="istio-system"
WORKDIR=tests/config/tmp
mkdir -p $WORKDIR

kubectl get configmap istio -n $ISTIO_NAMESPACE -o yaml >$WORKDIR/istio-configmap.yaml
mesh_config=$(yq eval-all '.data.mesh' $WORKDIR/istio-configmap.yaml | yq eval-all '. as $item ireduce ({}; . * $item )' - tests/config/istio-extension-providers-config.yaml)
data=$mesh_config yq eval-all ".data.mesh = strenv(data)" $WORKDIR/istio-configmap.yaml >$WORKDIR/istio-configmap-new.yaml
kubectl apply -f $WORKDIR/istio-configmap-new.yaml
kubectl rollout restart deployment/istiod -n $ISTIO_NAMESPACE

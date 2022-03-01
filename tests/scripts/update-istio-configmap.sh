#!/bin/bash

set -e

WORKDIR=tests/config/tmp
mkdir -p $WORKDIR

kubectl get configmap istio -n istio-system -o yaml >$WORKDIR/istio-configmap.yaml
mesh_config=$(yq eval-all '.data.mesh' $WORKDIR/istio-configmap.yaml | yq eval-all '. as $item ireduce ({}; . * $item )' - tests/config/istio-extension-providers-config.yaml)
data=$mesh_config yq eval-all ".data.mesh = strenv(data)" $WORKDIR/istio-configmap.yaml > $WORKDIR/istio-configmap-new.yaml
kubectl apply -f $WORKDIR/istio-configmap-new.yaml
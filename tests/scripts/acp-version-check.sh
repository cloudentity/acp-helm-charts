#!/bin/bash

ACP_VERSION="$(yq eval '(.dependencies[]|select(.name == "acp").version)' ./charts/kube-acp-stack/Chart.yaml)"
ACP_VERSION_IN_KUBE_ACP_STACK="$(yq eval '(.version)' ./charts/acp/Chart.yaml)"
echo "'acp' chart version is [$ACP_VERSION]"
echo "'acp' chart version in 'kube-acp-stack' chart is [$ACP_VERSION_IN_KUBE_ACP_STACK]"
if [ "$ACP_VERSION" == "$ACP_VERSION_IN_KUBE_ACP_STACK" ]
then
  echo "Versions are equal"
  exit 0
else
  echo "[ERROR] Versions are not equal"
  exit 1
fi

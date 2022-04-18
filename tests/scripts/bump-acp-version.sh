#!/bin/bash

set -e

HELM_CHARTS=$1
ACP_VERSION=$2

for CHART in ${HELM_CHARTS//,/ }
do
  if [[ "${CHART}" == "kube-acp-stack" ]]; then
    yq eval -i '.version = strenv(ACP_VERSION)' ./charts/${CHART}/Chart.yaml
    yq eval -i '.dependencies[] | select(.name == "acp").version = strenv(ACP_VERSION)' ./charts/${CHART}/Chart.yaml
  else
    yq eval -i '.version = strenv(ACP_VERSION)' ./charts/${CHART}/Chart.yaml
    yq eval -i '.appVersion = strenv(ACP_VERSION)' ./charts/${CHART}/Chart.yaml
  fi
done

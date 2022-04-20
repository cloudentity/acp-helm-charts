#!/bin/bash

set -e

HELM_CHARTS=$1
ACP_VERSION=$2

create-release-branch() {
  git checkout master && git checkout release/${ACP_VERSION} || git checkout -b release/${ACP_VERSION}
}

bump-acp-version() {
  for CHART in ${HELM_CHARTS//,/ }
  do
    if [[ "${CHART}" == "kube-acp-stack" ]]; then
      yq eval -i '.dependencies[] | select(.name == "acp").version = strenv(ACP_VERSION)' ./charts/${CHART}/Chart.yaml
    else
      yq eval -i '.appVersion = strenv(ACP_VERSION)' ./charts/${CHART}/Chart.yaml
    fi
  done
}

commit-release-branch() {
  git diff --quiet && git diff --staged --quiet || git commit --all --message "Bump acp version to ${ACP_VERSION}"
}

push-release-branch() {
  git config push.default current && git push origin release/${ACP_VERSION}:release/${ACP_VERSION}
}

create-release-branch
bump-acp-version
commit-release-branch
push-release-branch

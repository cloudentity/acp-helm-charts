#!/bin/bash

set -e

HELM_CHARTS=$1
ACP_VERSION=$2
CI=${CI:-false}

create-release-branch() {
  git stash
  git fetch
  git checkout master
  git checkout release/${ACP_VERSION} || git checkout -b release/${ACP_VERSION}
  git stash apply
}

bump-acp-version() {
  for CHART in ${HELM_CHARTS//,/ }
  do
    if [[ "${CHART}" == "kube-acp-stack" ]]; then
      yq eval -i '.version = strenv(ACP_VERSION)' ./charts/${CHART}/Chart.yaml
      yq eval -i '.dependencies[] |= select(.name == "acp").version = strenv(ACP_VERSION)' ./charts/${CHART}/Chart.yaml
    else
      yq eval -i '.version = strenv(ACP_VERSION)' ./charts/${CHART}/Chart.yaml
      yq eval -i '.appVersion = strenv(ACP_VERSION)' ./charts/${CHART}/Chart.yaml
    fi
  done
}

git-config() {
  git config --global user.name "Cloudentity CI"
  git config --global user.email devops@cloudentity.com
  git config --global push.default current
}

commit-release-branch() {
  git diff --quiet && git diff --staged --quiet || git commit --all --message "Bump acp version to ${ACP_VERSION}"
}

push-release-branch() {
  git push origin release/${ACP_VERSION}:release/${ACP_VERSION}
}

create-release-branch
bump-acp-version

if ${CI}; then
  git-config
  commit-release-branch
  push-release-branch
fi

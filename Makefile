### VARIABLES ###

# name of the chart on which targets will be perfomed
CHART ?= acp

# name of the Kubernetes Namespace where resources will be placed
NAMESPACE ?= acp-system


### TARGETS ###

# main targets
prepare: create-cluster base-stack

install: helm-install

verify: wait

test: helm-test

clean: delete-cluster clean-helm

# auxiliaries
create-cluster:
	kind create cluster \
		--name chart-test \
		--config tests/config/kind.yaml
	kubectl create namespace ${NAMESPACE}
	kubectl create secret docker-registry docker.cloudentity.io \
		--namespace ${NAMESPACE} \
		--docker-server=docker.cloudentity.io \
		--docker-username=${DOCKER_USER} \
		--docker-password=${DOCKER_PWD}

base-stack:
	mkdir --parents .kube-acp-stack-test
	cp ./charts/kube-acp-stack/Chart.yaml ./charts/kube-acp-stack/values.yaml .kube-acp-stack-test/
	yq eval '(.dependencies[]|select(.name == "acp").repository) |= "file://../charts/acp"' .kube-acp-stack-test/Chart.yaml --inplace
	helm dependency update .kube-acp-stack-test
	helm upgrade acp .kube-acp-stack-test \
		--values ./tests/config/kube-acp-stack.yaml \
		--namespace ${NAMESPACE} \
		--timeout 5m \
		--install

clean-helm:
	rm --recursive --force .kube-acp-stack-test

delete-cluster:
	kind delete cluster --name chart-test

docker:
	docker build --tag cloudentity/helm-tools - < Dockerfile

helm-lint:
	helm lint ./charts/${CHART}

helm-install:
	helm upgrade ${CHART} ${CHART} \
		--namespace ${NAMESPACE} \
		--timeout 5m \
		--install

helm-test:
	helm test ${CHART} --namespace ${NAMESPACE}

wait:
	kubectl wait deploy/${CHART} \
		--for condition=available \
		--namespace ${NAMESPACE} \
		--timeout 5m

debug:
	-kubectl get all --all-namespaces
	-kubectl logs daemonset/kindnet --namespace kube-system
	-kubectl logs daemonset/kube-proxy --namespace kube-system
	-kubectl logs deploy/coredns --namespace kube-system
	-kubectl logs deploy/local-path-provisioner --namespace local-path-storage
	-kubectl logs deploy/${CHART} --namespace ${NAMESPACE}
	-kubectl describe pod --selector app.kubernetes.io/name=${CHART} --namespace ${NAMESPACE}

check-kube-apis:
	docker run --rm --volume $(PWD)/charts/${CHART}:/data cloudentity/helm-tools \
		'sed "s/false/true/g" /data/values.yaml |\
		helm template --api-versions "networking.k8s.io/v1/Ingress" --values - /data |\
		pluto detect --ignore-deprecations --output wide -'

check-acp-charts-version:
	tests/scripts/acp-version-check.sh

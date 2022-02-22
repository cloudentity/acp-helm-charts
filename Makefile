# name of the chart on which targets will be perfomed
CHART ?= istio-authorizer
KUBE_ACP_STACK_CHART ?= kube-acp-stack
ACP_CHARTS_PATH = true

all: prepare deploy
prepare: create-cluster prepare-helm prepare-cluster
deploy: install-acp-stack

# cluster and tooling setup targets
create-cluster:
	kind create cluster \
		--name acp \
		--config ./config/kind-cluster-config.yaml

prepare-helm:
	helm repo add acp https://charts.cloudentity.io
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo add jetstack https://charts.jetstack.io
	helm repo update
ifdef ACP_CHARTS_PATH
	docker run --rm -v "${PWD}":/workdir mikefarah/yq \
		eval '(.dependencies[]|select(.name == "acp").repository) |= "file://../acp"' "charts/${KUBE_ACP_STACK_CHART}/Chart.yaml" --inplace
	helm dependency update "charts/${KUBE_ACP_STACK_CHART}"
endif

prepare-cluster:
	kubectl create namespace acp-system
	kubectl create namespace nginx
	kubectl create -n acp-system secret docker-registry docker.cloudentity.io \
		--docker-server=docker.cloudentity.io \
		--docker-username=${DOCKER_USER} \
		--docker-password=${DOCKER_PWD}

install-ingress-controller:
	helm upgrade ingress-nginx ingress-nginx/ingress-nginx \
		--values ./values/ingress-nginx.yaml \
		--namespace nginx \
		--timeout 2m \
		--install \
		--wait

install:
	helm upgrade ${CHART} charts/${CHART} \
		--values ./charts/${CHART}/values.yaml \
		--namespace acp-system \
		--timeout 10m \
		--install

install-acp-stack:
	helm upgrade acp charts/kube-acp-stack \
		--values ./tests/values/kube-acp-stack.yaml \
		--namespace acp-system \
		--timeout 10m \
		--install

wait:
	kubectl wait deploy/${CHART} \
		--for condition=available \
		--namespace acp-system \
		--timeout 5m

install-istio:
	curl --location https://istio.io/downloadIstio | ISTIO_VERSION=1.9.3 TARGET_ARCH=x86_64  sh -
	./istio-1.9.3/bin/istioctl install --filename ./config/ce-istio-profile.yaml --skip-confirmation
	kubectl label namespace default istio-injection=enabled
	rm --recursive --force ./istio-1.9.3

purge:
	-@for chart in $(shell ls charts); do helm uninstall $${chart} -n acp-system; done

delete-cluster:
	kind delete cluster --name acp

docker:
	docker build -t cloudentity/helm-tools - < Dockerfile

# chart-specific targets
helm-lint:
	helm lint ./charts/${CHART}

lint-kubeeval: docker
	docker run --rm -v $(shell pwd)/charts/${CHART}:/data cloudentity/helm-tools \
		"helm template 'lint' /data |\
		kubeval --skip-kinds AuthorizationPolicy"

# other targets
check-acp-charts-version:
	tests/scripts/acp-version-check.sh

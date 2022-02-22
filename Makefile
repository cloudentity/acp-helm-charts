# name of the chart on which targets will be perfomed
CHART ?= acp

docker:
	docker build --tag cloudentity/helm-tools - < Dockerfile

# chart-specific targets
helm-lint:
	helm lint ./charts/${CHART}

check-kube-apis:
	docker run --rm --volume $(PWD)/charts/${CHART}:/data cloudentity/helm-tools \
		'sed "s/false/true/g" /data/values.yaml |\
		helm template --api-versions "networking.k8s.io/v1/Ingress" --values - /data |\
		pluto detect --ignore-deprecations -o wide -'

# other targets
check-acp-charts-version:
	tests/scripts/acp-version-check.sh

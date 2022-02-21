# name of the chart on which targets will be perfomed
CHART ?= acp

docker:
	docker build -t cloudentity/helm-tools - < Dockerfile

# chart-specific targets
helm-lint:
	helm lint ./charts/${CHART}

check-kube-apis:
	docker run --rm -v $(PWD)/charts/${CHART}:/data cloudentity/helm-tools \
		'sed "s/false/true/g" /data/values.yaml |\
		helm template -a "networking.k8s.io/v1/Ingress" -f - /data |\
		pluto detect -'

# other targets
check-acp-charts-version:
	tests/scripts/acp-version-check.sh

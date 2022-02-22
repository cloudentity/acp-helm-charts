# name of the chart on which targets will be perfomed
CHART ?= acp

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

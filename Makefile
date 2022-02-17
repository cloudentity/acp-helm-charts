# name of the chart on which targets will be perfomed
CHART = 

# chart-specific targets
helm-lint:
	helm lint ./charts/${CHART}

# other targets
check-acp-charts-version:
	tests/scripts/acp-version-check.sh

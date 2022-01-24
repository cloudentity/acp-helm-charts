### MAIN TARGETS ###
prepare: create-cluster prepare-helm prepare-cluster

deploy: install-ingress-controller install-acp

clean: uninstall-acp uninstall-ingress-controller delete-cluster clean-helm

### AUXILIARIES ###
create-cluster:
	kind create cluster \
		--name acp \
		--config ./config/kind-config.yaml

prepare-helm:	
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo add jetstack https://charts.jetstack.io
	helm repo update
	mkdir ./charts/.kube-acp-stack-test
	cp ./charts/kube-acp-stack/Chart.yaml ./charts/kube-acp-stack/values.yaml ./charts/.kube-acp-stack-test/
	yq eval '(.dependencies[]|select(.name == "acp").repository) |= "file://../acp"' ./charts/.kube-acp-stack-test/Chart.yaml --inplace
	helm dependency update ./charts/.kube-acp-stack-test

prepare-cluster:
	kubectl create namespace nginx
	kubectl create namespace acp-system
	kubectl create secret docker-registry docker.cloudentity.io \
		--namespace acp-system \
		--docker-server=docker.cloudentity.io \
		--docker-username=${DOCKER_USER} \
		--docker-password=${DOCKER_PWD}

install-acp:
	helm upgrade acp ./charts/.kube-acp-stack-test \
		--values ./config/kube-acp-stack.yaml \
		--namespace acp-system \
		--timeout 5m \
		--install \
		--wait

install-ingress-controller:
	helm upgrade ingress-nginx ingress-nginx/ingress-nginx \
		--values ./config/ingress-nginx.yaml \
		--namespace nginx \
		--timeout 2m \
		--install \
		--wait

uninstall-acp:
	helm uninstall acp --namespace acp-system

uninstall-ingress-controller:
	helm uninstall ingress-nginx --namespace nginx

clean-helm:
	rm --recursive --force ./charts/.kube-acp-stack-test
	helm repo remove ingress-nginx jetstack cockroachdb

delete-cluster:
	kind delete cluster --name=acp

lint:
	helm lint ./charts/*

debug:
	-kubectl get all --all-namespaces
	-kubectl logs daemonset/kindnet --namespace kube-system
	-kubectl logs daemonset/kube-proxy --namespace kube-system 
	-kubectl logs deploy/acp --namespace acp-system
	-kubectl logs deploy/ingress-nginx-controller --namespace nginx
	-kubectl logs deploy/coredns --namespace kube-system
	-kubectl logs deploy/local-path-provisioner --namespace local-path-storage
	-kubectl describe pods/acp --namespace acp

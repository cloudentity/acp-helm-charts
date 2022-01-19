### MAIN TARGETS ###
prepare: create-cluster prepare-helm prepare-cluster

deploy: install-ingress-controller install-acp

clean: uninstall-acp uninstall-ingress-controller delete-cluster

### AUXILIARIES ###
create-cluster:
	kind create cluster \
		--name acp \
		--config ./config/kind-config.yaml

prepare-helm:	
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo add jetstack https://charts.jetstack.io
	helm repo update

prepare-cluster:
	kubectl create namespace nginx
	kubectl create namespace acp-system

install-acp:
	helm upgrade acp ./charts/kube-acp-stack \
		--values ./config/kube-acp-stack.yaml \
		--namespace acp-system \
		--timeout 5m \
		--install \
		--wait

install-ingress-controller:
	helm upgrade ingress-nginx ingress-nginx/ingress-nginx \
		--values ./config/ingress-nginx.yaml \
		--namespace nginx \
		--timeout 1m \
		--install \
		--wait

uninstall-acp:
	helm uninstall acp --namespace acp-system

uninstall-ingress-controller:
	helm uninstall ingress-nginx --namespace nginx

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
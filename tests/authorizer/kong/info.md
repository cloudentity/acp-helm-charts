# Prepare plugin for kong

## Setup configmap

```shell
kubectl create namespace kong-system
kubectl create configmap kong-plugin-acp \
     --namespace kong-system \
     --from-file=tests/authorizer/kong/lua/
```

## clean

```shell
kubectl delete configmaps -n kong-system kong-plugin-acp
```

## Setup auth

```shell
curl -sSk -X POST http://localhost:8001/services/httpbin-service/plugins \
     --data 'name=kong-plugin-acp' \
     --data 'config.api_group_id=httpbin-service' \
     --data 'config.auth_url=https://kong-authorizer.kong-authorizer:9003/authorize' \
     --data 'config.ssl_verify=false'
```

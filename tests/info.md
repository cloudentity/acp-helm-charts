#

```shell
curl -sSk -X POST http://localhost:8001/services/httpbin-service/plugins \
     --data 'name=acp' \
     --data 'config.api_group_id=httpbin-service' \
     --data 'config.auth_url=https://kong-authorizer.kong-authorizer:9003/authorize' \
     --data 'config.ssl_verify=false'
```

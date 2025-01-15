# ACP

[Cloudentity](https://cloudentity.com/) Authorization Control Plane (ACP) is a cutting edge platform for the API access control. ACP consolidates capabilities of a modern OAuth/OIDC server with an advanced authorization, consent management, and developer enablement.

This chart bootstraps a [ACP](https://github.com/cloudentity/acp-helm-charts/tree/master/charts/acp) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.16+
- Helm 3+

## Get Repo Info

```console
helm repo add acp https://charts.cloudentity.io
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
# Helm
$ helm install [RELEASE_NAME] acp/acp
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
# Helm
$ helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
# Helm
$ helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### From 2.23.1 to 2.23.2

Version 2.23.2 of ACP helm chart uses `docker.secureauth.com` as the secret name referencing SecureAuth registry.
If you're using the `docker.cloudentity.io` and haven't overridden `imagePullSecrets` before, you have to create a new secret with the name `docker.secureauth.com`
See [Docker Pull Credentials](#docker-pull-credentials).

### Update to 2.21.0

* Support for docker faas envs has beed added at `faas.environments`
* support for creating faas namespace has beed added at `faas.namespace.create`

Below `fission` values have beed moved to support new environments format

| Old Configuration                 | New Configuration                                    |
|-----------------------------------|------------------------------------------------------|
| `fission.enabled`                 | `faas.enabled` and `faas.provider="fission"`.          |
| `fission.namespace`               | `faas.namespace.name`                                |
| `fission.poolsize`                | `faas.environments.settings.replicaCount`            |
| `fission.podSecurityContext`      | `faas.environments.settings.podSecurityContext`      |
| `fission.containerSecurityContext`| `faas.environments.settings.containerSecurityContext`|
| `fission.annotations`             | `faas.environments.settings.annotations`             |
| `fission.imagePullPolicy`         | `faas.environments.settings.imagePullPolicy`         |
| `fission.imagepullsecret`         | `faas.environments.settings.imagepullsecret`         |
| `fission.affinity`                | `faas.environments.settings.affinity`                |
| `fission.resources`               | `faas.environments.settings.resources`               |
| `fission.node`                    | `faas.environments.node`                             |
| `fission.rego`                    | `faas.environments.rego`                             |
| `fission.images.node`             | `faas.environments.node.<version>.image`             |
| `fission.images.rego`             | `faas.environments.rego.<version>.image`             |

### Update to 2.15.0

Please skip version 2.15.0 and go directly to 2.15.1. 2.15.0 has a problematic node-env version (4.1) which does not support read-only file systems.

### From 2.4.0 to 2.4.1

`IngressMtls.secret` was renamed to `IngressMtls.tlsSecrets` to match other ingress format. Type was changed from map to array.
`IngressMtls.tls` configuration was added.

### Upgrade from 0.17.x to 2.0.0

No breaking changes. Helm charts were updated to match ACP version.

### From 0.15.0 to 0.15.1

Version 0.15.1 of ACP helm chart uses `docker.cloudentity.io` as the secret name referencing Cloudentity registry.
If you're using the `artifactory` and haven't overridden `imagePullSecrets` before, you have to create a new secret with the name `docker.cloudentity.io`
See [Docker Pull Credentials](#docker-pull-credentials).

### From 0.9.x to 0.10.x

Version 1.10.0 of ACP changes the key names in feature flags from camelCase to snake_case [values.yaml](https://github.com/cloudentity/acp-helm-charts/commit/e150d8c713bc1b7eae0f5d272b77071b0c0b29bf#diff-8bff71ce1c243a3af0288410a6f5900e2c5d5bde86fbcbf8124615970237759a).

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
$ helm show values acp/acp
```

You may similarly use the above configuration commands on each chart [dependency](#dependencies) to see it's configurations.

### Docker Pull Credentials

ACP defines Pod that uses a Secret to pull an image from a private Docker registry or repository, please refer to the documentation for that mechanism ([Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/))

To manually configure Docker credentials, first createreate a Secret by providing credentials on the command line:

```console
kubectl create secret docker-registry docker.cloudentity.io --docker-server=docker.cloudentity.io --docker-username=<your-name> --docker-password=<your-password>
```

### RBAC Configuration

Roles and RoleBindings resources will be created automatically for `acp` service.

To manually setup RBAC you need to set the parameter `rbac.create=false` and specify the service account to be used for each service by setting the parameters: `serviceAccounts.{{ component }}.create` to `false` and `serviceAccounts.{{ component }}.name` to the name of a pre-existing service account.

> **Tip**: You can refer to the default `*-clusterrole.yaml` and `*-clusterrolebinding.yaml` files in [templates](templates/) to customize your own.

### ConfigMap Files

ACP is configured through [config.yml](...). This file (and any others listed in `configFiles`) will be mounted into the `acp` pod.

### Ingress TLS

If your cluster allows automatic creation/retrieval of TLS certificates (e.g. [cert-manager](https://github.com/jetstack/cert-manager)), please refer to the documentation for that mechanism.

To manually configure TLS, first create/retrieve a key & certificate pair for the address(es) you wish to protect. Then create a TLS secret in the namespace:

```console
kubectl create secret tls acp-server-tls --cert=path/to/tls.cert --key=path/to/tls.key
```

Include the secret's name, along with the desired hostnames, in the alertmanager/server Ingress TLS section of your custom `values.yaml` file:

```yaml
acp:
  ingress:
    ## If true, ACP Ingress will be created
    ##
    enabled: true

    ## ACP Ingress hostnames
    ## Must be provided if Ingress is enabled
    ##
    hosts:
      - acp.domain.com

    ## ACP Ingress TLS configuration
    ## Secrets must be manually created in the namespace
    ##
    tls:
      - secretName: acp-server-tls
        hosts:
          - acp.domain.com
```

## Fission

Install the [fission](https://fission.io/docs/installation/).

### Docker Pull Credentials

Fission environment defines Pod that uses a Secret to pull an image from a private Docker registry or repository, please refer to the documentation for that mechanism ([Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/))

To manually configure Docker credentials, first create a Secret by providing credentials on the command line:

```console
kubectl create secret -n <faas.namespace> docker-registry docker.secureauth.com --docker-server=docker.secureauth.com --docker-username=<your-name> --docker-password=<your-password>
```

> **Note**: `faas.namespace` can be defined in [values.yaml](./values.yaml):
>
>```yaml
>faas:
>  namespace: acp-faas
>```

### Configuration

To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), faas section. By default Faas Environment for ACP is disabled. To enable switch the flag `faas.enabled` to `true` and `faas.provider` to `fission`:

```yaml
faas:
  enabled: true
  provider: "fission"
```

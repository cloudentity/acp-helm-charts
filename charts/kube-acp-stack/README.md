# kube-acp-stack

> [!IMPORTANT]
> Please note that this repository is deprecated. It will continue to receive version updates for internal purposes only. For deploying the ACP stack, we strongly recommend using [Cloudentity's ACP on Kubernetes](https://github.com/cloudentity/acp-on-k8s).

Installs the [acp](https://github.com/cloudentity/acp-helm-charts/tree/master/charts/acp), a collection of Kubernetes manifests, [CockroachDB](https://www.cockroachlabs.com/) open source, cloud-native distributed SQL database, and [Redis](https://redis.io/) in-memory data grid combined with documentation and scripts to provide easy to operate end-to-end Authorization Control Plane cluster.

See the [acp](https://github.com/cloudentity/acp-helm-charts/tree/master/charts/acp) README for details about components, capabilities of OAuth/OIDC server with an advanced authorization, consent management, and developer enablement.

## Prerequisites

- Kubernetes 1.16+
- Helm 3+

## Get Repo Info

```console
helm repo add acp https://charts.cloudentity.io
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Create Role and RoleBinding
Inorder to fix the know issue, create a Role and RoleBinding. Please download the manifest file: timescale-role-binding.yaml from acp-helm-charts/tests/config and run the following command.

```console
$ kubectl apply -f timescale-role-binding.yaml
```

## Install Chart

```console
# Helm
$ helm install [RELEASE_NAME] acp/kube-acp-stack
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Dependencies

By default this chart installs additional, dependent charts:

- [acp/acp](https://github.com/cloudentity/acp-helm-charts/tree/master/charts/acp)
- [cockroachdb/cockroachdb](https://github.com/cockroachdb/helm-charts/tree/master/cockroachdb)
- [redis-cluster/redis-cluster](https://github.com/bitnami/charts/tree/master/bitnami/redis-cluster)

To disable dependencies during installation, see [multiple releases](#multiple-releases) below.

_See [helm dependency](https://helm.sh/docs/helm/helm_dependency/) for command documentation._

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
$ helm upgrade [RELEASE_NAME] acp/kube-acp-stack
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### From 2.23.1 to 2.23.2

Version 2.23.2 of ACP kube stack helm chart uses `docker.secureauth.com` as the secret name referencing SecureAuth registry.
If you're using the `docker.cloudentity.io` and haven't overridden `imagePullSecrets` before, you have to create a new secret with the name `docker.secureauth.com`
See [Docker Pull Credentials](#docker-pull-credentials).

### From 2.x to 2.13.1

Default values for charts dependencies now set `fullnameOverride` to standarize database connection URLs. Users that want to keep old databases naming should set this values to `null`.

### From 2.6.0 to 2.7.3

Timescaledb helm chart is introduced as a dependency. With this, timescaledb gets installed and configured in addition to the existing components and acp is able to make connection with timescaledb with default or custom configuration.

### From 0.14.x, 0.15.3 to 0.16.3

Dependency redis helm chart was replaced by redis-cluster helm chart. The old redis instances will be destroyed in favour of new redis-cluster. Data migration is not supported but could be done manually which is out of the scope of this chart.

### From 0.14.x to 0.15.3

Version 0.15.1 of ACP kube stack helm chart uses `docker.cloudentity.io` as the secret name referencing Cloudentity registry.
If you're using the `artifactory` and haven't overridden `imagePullSecrets` before, you have to create a new secret with the name `docker.cloudentity.io`
See [Docker Pull Credentials](#docker-pull-credentials).

### From 0.15.x to 0.15.3

Due to bug in ACP, redis-cluster implementation was reverted back to redis helm chart. Redis multi-master instances will be destroyed and recreated as master-replica. Data migration is not supported but could be done manually which is out of the scope of this chart.

### From 0.15.0 to 0.15.1 

Version 0.15.1 of ACP kube stack helm chart uses `docker.cloudentity.io` as the secret name referencing Cloudentity registry.
If you're using the `artifactory` and haven't overridden `imagePullSecrets` before, you have to create a new secret with the name `docker.cloudentity.io`
See [Docker Pull Credentials](#docker-pull-credentials).

### From 0.14.x to 0.15.0, 0.15.1, 0.15.2

!Releases 0.15.0, 0.15.1 and 0.15.2 shloud not be used due connectivity issues with redis. ACP might randomly fail to connect to redis. This is resolved in 0.16.3!

Dependency redis helm chart was replaced by redis-cluster helm chart. The old redis instances will be destroyed in favour of new redis-cluster. Data migration is not supported but could be done manually which is out of the scope of this chart.

### From 0.6.x to 0.7.x

Version 1.10.0 of ACP changes the key names in feature flags from camelCase to snake_case [values.yaml](https://github.com/cloudentity/acp-helm-charts/commit/e150d8c713bc1b7eae0f5d272b77071b0c0b29bf#diff-8bff71ce1c243a3af0288410a6f5900e2c5d5bde86fbcbf8124615970237759a).

### Upgrading an existing Release to a new major version

A major chart version change (like v1.2.3 -> v2.0.0) indicates that there is an incompatible breaking change needing manual actions.

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments:

```console
helm show values acp/kube-acp-stack
```

You may also `helm show values` on this chart's [dependencies](#dependencies) for additional options.

## Work-Arounds for Known Issues

TBD

## Further Information

For more in-depth documentation of configuration options meanings, please see

- [ACP](https://github.com/cloudentity/acp-helm-charts)
- [CockroachDB](https://github.com/cockroachdb/helm-charts)
- [redis-cluster](https://github.com/bitnami/charts)

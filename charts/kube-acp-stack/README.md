# kube-acp-stack

Installs the [acp](https://github.com/cloudentity/acp-helm-charts/tree/master/charts/acp), a collection of Kubernetes manifests, [CockroachDB](https://www.cockroachlabs.com/) open source, cloud-native distributed SQL database, and [Hazelcast](https://hazelcast.com/) in-memory data grid combined with documentation and scripts to provide easy to operate end-to-end Authorization Control Plane cluster.

See the [acp](https://github.com/cloudentity/acp-helm-charts/tree/master/charts/acp) README for details about components, capabilities of OAuth/OIDC server with an advanced authorization, consent management, and developer enablement.

## Prerequisites

- Kubernetes 1.16+
- Helm 3+

## Get Repo Info

```console
helm repo add acp https://artifactory.cloudentity.com/acp-helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

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
- [hazelcast/hazelcast](https://github.com/hazelcast/charts/tree/master/stable/hazelcast)

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

- [ACP](https://artifactory.cloudentity.com/acp-helm-charts)
- [CockroachDB](https://github.com/cockroachdb/helm-charts)
- [Hazelcast](https://github.com/hazelcast/charts)

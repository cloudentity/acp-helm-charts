# Cloudentity Istio Authorizer

[Cloudentity](https://cloudentity.com/) Authorization Control Plane (ACP) is a cutting edge platform for the API access control. ACP consolidates capabilities of a modern OAuth/OIDC server with an advanced authorization, consent management, and developer enablement.

This chart bootstraps [istio-authorizer](https://docs.authorization.cloudentity.com/guides/developer/protect/istio/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

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
$ helm install [RELEASE_NAME] acp/istio-authorizer
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

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
$ helm show values acp/istio-authorizer
```

You may similarly use the above configuration commands on each chart [dependency](#dependencies) to see it's configurations.

### Docker Pull Credentials

Istio authorizer defines Pod that uses a Secret to pull an image from a private Docker registry, please refer to the documentation for that mechanism ([Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/))

To manually configure Docker credentials, first create a Secret by providing credentials on the command line:

```console
kubectl create secret docker-registry docker.cloudentity.io --docker-server=docker.cloudentity.io --docker-username=<your-name> --docker-password=<your-password>
```

### Prerequisites for deploying and protecting services

#### Define the authorizer

Edit the mesh config with the following command:

```sh
kubectl edit configmap istio -n istio-system
```

Define acp authorizer using extension providers, for example:

```yaml
data:
  mesh: |-
    extensionProviders:
    - name: "acp-authorizer"
      envoyExtAuthzGrpc:
        service: "istio-authorizer.acp-system.svc.cluster.local"
        port: "9001"
```

Restart Istio to apply the changes:

```sh
kubectl rollout restart deployment/istiod -n istio-system
```

For details please follow [Prerequisites for deploying and protecting services](https://docs.authorization.cloudentity.com/guides/developer/protect/istio/prerequisites/) article.

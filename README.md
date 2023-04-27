# Azure Pipelines Agent

<!-- Use absolute path for images in README.md, so that they are displayed on ArtifactHub.io, Lens, OpenLens, etc. -->
<img src="https://raw.githubusercontent.com/clemlesne/azure-pipelines-agent/main/logo-4096.png" width="100">

[Azure Pipelines Agent](https://github.com/clemlesne/azure-pipelines-agent) is self-hosted agent in Kubernetes, cheap to run, secure, auto-scaled and easy to deploy.

<!-- github.com badges -->
[![Project licence](https://img.shields.io/github/license/clemlesne/azure-pipelines-agent)](https://github.com/clemlesne/azure-pipelines-agent/blob/main/LICENCE)
[![Last release date](https://img.shields.io/github/release-date/clemlesne/azure-pipelines-agent)](https://github.com/clemlesne/azure-pipelines-agent/releases)
[![Workflow status](https://img.shields.io/github/actions/workflow/status/clemlesne/azure-pipelines-agent/pipeline.yaml?branch=main)](https://github.com/clemlesne/azure-pipelines-agent/actions/workflows/pipeline.yaml)
[![All releases download counter](https://img.shields.io/github/downloads/clemlesne/azure-pipelines-agent/total)](https://github.com/clemlesne/azure-pipelines-agent/pkgs/container/azure-pipelines-agent)

<!-- artifacthub.io badges -->
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/azure-pipelines-agent)](https://artifacthub.io/packages/search?repo=azure-pipelines-agent)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/azure-pipelines-agent-container)](https://artifacthub.io/packages/search?repo=azure-pipelines-agent-container)

Features:

- Agent register and restart itself.
- Allow to build containers inside the agent using [BuildKit](https://github.com/moby/buildkit).
- Can run air-gapped (no internet access).
- Cheap to run (dynamic provisioning of agents, can scale from 0 to 100+ in few seconds with [KEDA](https://keda.sh)).
- Performances can be customized depending of the engineering needs, which goes far beyond the Microsoft-hosted agent.
- Pre-built with Windows Server, Debian, Ubuntu, Red Hat Enterprise Linux.
- SBOM (Software Bill of Materials) is packaged with each container image.
- System updates are applied every days.

## Usage

Deployment steps:

1. [Prepare the token for allowing access from the Agent to Azure DevOps.](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops#permissions)
2. Deployment in Kubernetes using Helm

### Deployment in Kubernetes using Helm

Minimal configuration:

```yaml
pipelines:
  url: https://dev.azure.com/your-organization
  pat: your-pat
  pool: your-pool
```

Use Helm to install the latest released chart:

```bash
helm repo add clemlesne-azure-pipelines-agent https://clemlesne.github.io/azure-pipelines-agent
helm repo update
helm upgrade --install agent clemlesne-azure-pipelines-agent/azure-pipelines-agent
```

## Compatibility

| Ref | OS | Arch | Support |
|-|-|-|-|
| `docker pull ghcr.io/clemlesne/azure-pipelines-agent:bullseye-main` | Debian Bullseye (11) slim | `linux/amd64`, `linux/arm/v7`, `linux/arm64/v8` | [See Debian LTS wiki.](https://wiki.debian.org/LTS) |
| `docker pull ghcr.io/clemlesne/azure-pipelines-agent:focal-main` | Ubuntu Focal (20.04) minimal | `linux/amd64`, `linux/arm/v7`, `linux/arm64/v8` | [See Ubuntu LTS wiki.](https://wiki.ubuntu.com/Releases) |
| `docker pull ghcr.io/clemlesne/azure-pipelines-agent:jammy-main` | Ubuntu Jammy (22.04) minimal | `linux/amd64`, `linux/arm/v7`, `linux/arm64/v8` | [See Ubuntu LTS wiki.](https://wiki.ubuntu.com/Releases) |
| `docker pull ghcr.io/clemlesne/azure-pipelines-agent:ubi8-main` | Red Hat UBI 8 (8.7) minimal | `linux/amd64`, `linux/arm64/v8` | [See Red Hat product life cycles.](https://access.redhat.com/product-life-cycles/?product=Red%20Hat%20Enterprise%20Linux) |
| `docker pull ghcr.io/clemlesne/azure-pipelines-agent:win-ltsc2019` | Windows Server 2019 Core | `linux/amd64` | [See base image servicing lifecycles.](https://learn.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/base-image-lifecycle) |
| `docker pull ghcr.io/clemlesne/azure-pipelines-agent:win-ltsc2022` | Windows Server 2022 Core | `linux/amd64` | [See base image servicing lifecycles.](https://learn.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/base-image-lifecycle) |

## Advanced topics

### Provided software

#### Linux

- [Azure Pipelines agent](https://github.com/microsoft/azure-pipelines-agent) (see env var `AZP_AGENT_VERSION` on the container images) + [requirements](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops#linux)
- [ASP.NET Core](https://github.com/dotnet/aspnetcore) runtime (required by the Azure Pipelines agent)
- [Azure CLI](https://github.com/Azure/azure-cli) (required by the Azure Pipelines agent) + requirements ([Python 3.8](https://www.python.org/downloads/release/python-380), [Python 3.9](https://www.python.org/downloads/release/python-390), [Python 3.10](https://www.python.org/downloads/release/python-3100), depending of the system, plus C/Rust build tools for libs non pre-built on the platforms)
- [PowerShell Core](https://github.com/PowerShell/PowerShell), [bash](https://www.gnu.org/software/bash) and [zsh](https://www.zsh.org) (for inter-operability)
- [BuildKit](https://github.com/moby/buildkit) + requirements ([dbus-user-session](https://dbus.freedesktop.org), [fuse-overlayfs](https://github.com/containers/fuse-overlayfs), [iptables](https://www.netfilter.org/projects/iptables/index.html), [shadow-utils](https://github.com/shadow-maint/shadow), [uidmap](https://github.com/shadow-maint/shadow))
- [gzip](https://www.gnu.org/software/gzip), [jq](https://github.com/stedolan/jq), [make](https://www.gnu.org/software/make), [tar](https://www.gnu.org/software/tar), [unzip](https://infozip.sourceforge.net/UnZip.html), [wget](https://www.gnu.org/software/wget), [yq](https://github.com/mikefarah/yq), [zip](https://infozip.sourceforge.net/Zip.html), [zstd](https://github.com/facebook/zstd) (for developer ease-of-life)

#### Windows

- [Azure Pipelines agent](https://github.com/microsoft/azure-pipelines-agent) (see env var `AZP_AGENT_VERSION` on the container images) + [requirements](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops#linux)
- [ASP.NET Core](https://github.com/dotnet/aspnetcore) runtime (required by the Azure Pipelines agent)
- [Azure CLI](https://github.com/Azure/azure-cli) (required by the Azure Pipelines agent)
- [PowerShell Core](https://github.com/PowerShell/PowerShell) (for inter-operability)
- [git](https://github.com/git-for-windows/git), [jq](https://github.com/stedolan/jq), [yq](https://github.com/mikefarah/yq) (for developer ease-of-life)

### Capabilities

Capabilities are declarative variables you can add to the agents, to allow developers to select the right agent for their pipeline ([official documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/demands?view=azure-devops&tabs=yaml)).

> Note, you can add multiple Helm instances to the same agent pool. It will result in a single pool with multiple capabilities. Be warning, if a capability is not unique accross the pool, all the agents will scale. This will create "zoombies" agents, scaled for nothing, waiting their timeout.

Disctinct the agents by capabilities. For examples:

- A pool of X64 agents, and a pool of ARM64 agents
- A pool of agents with GPU, and a pool of agents without GPU
- A pool of agents with low performance (standard usage), and a pool of agents with high performance (IA training, intensive C/Rust/GraalVM compilation, ...), with distinct Kubernetes Node pool, scaling to 0 when not used ([AKS documentation](https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler))

#### Example: ARM64 agents

Take the assumption we want to host a specific instance pool to ARM servers.

```yaml
# values.yaml
pipelines:
  pool: private_kube
  capabilities:
    - arch_arm64

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/arch
            operator: In
            values:
              - arm64
```

Deploy the Helm instance:

```bash
❯ helm upgrade --install agent-arm64 clemlesne-azure-pipelines-agent/azure-pipelines-agent -f values.yaml
```

Update the Azure Pipelines file in the repository to use the new pool:

```yaml
# azure-pipelines.yaml
pool:
  name: private_kube
  demands:
    - arch_arm64

stages:
  ...
```

#### Example: Use different agents on specific jobs

In that example:

- We are using a default agent on ARM64
- Semgrep, our SAST tool, is not compatible with ARM64, let's use X64 pool
- Our devs are working on a Java project, built with GraalVM, and the container is built locally with [img](https://github.com/genuinetools/img#running-with-kubernetes): we need a system lot of RAM and multipe CPUs for building the application

Our problematic:

- Is it possible to reconcile the efficiency of these different architectures, without restricting ourselves?
- Do we necessarily have to install high performance agents when the use of these large constructions is only a small part of the total execution time (tests, deployments, monitoring, rollback, external services, ...)?

We decide to dpeloy these agents:

| Details | Efficiency (cost, perf, energy) | Capabilities |
|-|-|-|
| Standard performance, ARM64 | ≅ x1 | `arch_arm64`, `perf_standard` |
| Standard performance, X64 | ≅ x1.5 | `arch_x64`, `perf_standard` |
| High performance, ARM64 | ≅ x10 | `arch_x64`, `perf_high` |
| High performance, X64 | ≅ x15 | `arch_arm64`, `perf_high` |

The developer can now use:

```yaml
# azure-pipelines.yaml
pool:
  name: private_kube
  demands:
    - arch_arm64
    - perf_standard

stages:
  - stage: build
    jobs:
      - job: sast
        # Use X64 Linux agent because Semgrep is not available on ARM64
        # See: https://github.com/returntocorp/semgrep/issues/2252
        pool:
          name: private_kube
          demands:
            - arch_x64
            - perf_standard
      - job: unit_tests
      - job: container
        # Use high performance agent as Java GraalVM compilation is complex
        pool:
          name: private_kube
          demands:
            - arch_x64
            - perf_high
  - stage: deploy
    jobs:
      - job: upgrade
      - job: dast
      - job: integration_tests
```

### Build container images in the agent

#### Introduction

These methods can be used to build a container image, at the time of writing:

| Software | Ease | Security | Perf | Run location | Description |
|-|-|-|-|-|-|
| [Azure Container Registry task](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tasks-overview#quick-task), [Google Cloud Build](https://cloud.google.com/build/docs/building/build-containers) | 🟩🟩🟥 | 🟩🟩🟩 | 🟩🟩🟩 | Managed environment | A managed service build the container image in a dedicated environment. |
| [Kaniko](https://github.com/GoogleContainerTools/kaniko#running-kaniko-in-a-kubernetes-cluster) | 🟩🟥🟥 | 🟩🟩🟩 | 🟩🟩🟥 | Self-hosted Kubernetes | A Pod is created for each build, taking care of building and pushing the container to the registry. No security drawbacks. |
| [img](https://github.com/genuinetools/img#running-with-kubernetes), [BuildKit](https://github.com/moby/buildkit) | 🟩🟩🟩 | 🟩🟩🟥 | 🟩🟥🟥 | Local CLI | CLI to build the images. Can build different architectures on a single machine. Requires [Seccomp](https://en.wikipedia.org/wiki/Seccomp) disabled and [AppArmor](https://apparmor.net) disabled. |
| Docker in docker | 🟩🟩🟩 | 🟥🟥🟥 | 🟩🟩🟩 | Local CLI | Before Kubernetes 1.20, it was possible to build container images in the agent, using the Docker socket. This is not possible anymore, as Kubernetes [deprecated the Docker socket](https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker) in favor of the [Container Runtime Interface](https://kubernetes.io/blog/2016/12/container-runtime-interface-cri-in-kubernetes). |

We choose BuildKit for this project. [Its licence](https://raw.githubusercontent.com/moby/buildkit/v0.11.5/LICENSE) allows commercial use, and the project and mainly maintained, as the time of writing, by Docker, Netlix and Microsoft.

#### How to use the bundled BuildKit

There are two components, the backend, `buildkitd`, and the CLI, `buildctl`.

Requirements:

- Setup special security requirements, you can find them [in the example file `container-build.yaml`](example/helm/container-build.yaml).
- In the pipeline, run `buildkitd` before using `buildctl`.

```yaml
# azure-pipelines.yaml
variables:
  - name: container_name
    value: my-app
  - name: container_registry_domain
    value: my-app-registry.azurecr.io

steps:
  - bash: |
      # Start buildkitd
      rootlesskit buildkitd --oci-worker-no-process-sandbox --addr $BUILDKIT_HOST &
      # Wait for buildkitd to start
      while ! buildctl debug workers; do sleep 1; done
    displayName: Run BuildKit

  - bash: |
      buildctl build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --output type=image,name=$(container_registry_domain)/$(container_name):latest,push=true
    displayName: Build and push the image
```

Out of the box, argument `--opt platform=linux/amd64,linux/arm64` can be added to build an image compatible with multiple architectures ([more can be specified](https://github.com/moby/buildkit/blob/v0.11.5/docs/multi-platform.md)). Multiple cache strategies [are available](https://github.com/moby/buildkit/tree/v0.11.5#cache) (including container registry, Azure Storage Blob, AWS S3).

#### BuildKit and the performance

BuildKit works by virtualization in the user space. You can't expect build times as short as native (on your laptop for example). [QEMU](https://www.qemu.org) is used as a backend. This has the advantage of being able to create images for different architectures than your processor. Virtualization-wise, not all CPU models are equivalent, you can [refer to the official project documentation](https://www.qemu.org/docs/master/system/qemu-cpu-models.html) to select the most appropriated CPU model for your Kubernetes Node Pool.

### Build ASP.NET applications in the agent

It was chosen arbitrarily to install the LTS non SDK version of ASNP.NET. Because :

- LTS is better supported by Microsoft than STS
- The non-SDK is lighter when included in a container, knowing that not everyone will use it for building purposes

It is recommended that development teams to hard-code the framework version you want to use, in your pipeline. With this setup, the developer controls its environment, not the platform. If they decide to upgrade, they update the pipeline, if not, not. This is under the responsibility of the developer.

The ASP.NET framework can be installed on the fly with [UseDotNet@2](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/use-dotnet-v2?view=azure-pipelines):

```yaml
# azure-pipelines.yaml
steps:
  - task: UseDotNet@2
    inputs:
      packageType: sdk
      version: 7.0.5
```

Same way, if you want to use multiple versions of the framework, re-execute the task with the new version. Installations are cached locally.

### Helm values

| Parameter | Description | Default |
|-|-|-|
| `additionalEnv` | Additional environment variables for the agent container. | `[]` |
| `affinity` | Node affinity for pod assignment | `{}` |
| `annotations` | Add custom annotations to the Pod. | `{}` |
| `autoscaling.cooldown` | Time in seconds the automation will wait until there is no more pipeline asking for an agent. Same time is then applied for system termination. | `60` |
| `autoscaling.enabled` | Enable the auto-scaling. Requires [KEDA](https://keda.sh), but can be started without. Be warning, disabling auto-scaling implies a shutdown of the existing agents during a Helm instance upgrade, according to `pipelines.timeout`. | `true` |
| `autoscaling.maxReplicas` | Maximum number of pods, remaining jobs will be kept in queue. | `100` |
| `extraNodeSelectors` | Additional node labels for pod assignment. | `{}` |
| `extraVolumeMounts` | Additional volume mounts for the agent container. | `[]` |
| `extraVolumes` | Additional volumes for the agent pod. | `[]` |
| `fullnameOverride` | Overrides release fullname | `""` |
| `image.flavor` | Container image tag, can be `bullseye`, `focal`, `jammy`, or `ubi8`. | `bullseye` |
| `image.isWindows` | Turn on is the agent is a Windows-based system. | `false` |
| `image.pullPolicy` | Container image pull policy | `IfNotPresent` |
| `image.repository` | Container image repository | `ghcr.io/clemlesne/azure-pipelines-agent:bullseye` |
| `image.version` | Container image tag | *Version* |
| `imagePullSecrets` | Use secrets to pull the container image. | `[]` |
| `initContainers` | InitContainers for the agent pod. | `[]` |
| `nameOverride` | Overrides release name | `""` |
| `pipelines.cacheSize` | Total cache to attach to the Azure Pipelines standard directory. By default, [same amount as the Microsoft Hosted agents](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops&tabs=yaml#hardware). | `10Gi` |
| `pipelines.cacheType` | Disk type to attach to the Azure Pipelines standard directory. See your cloud provider for types ([Azure](https://learn.microsoft.com/en-us/azure/aks/concepts-storage#storage-classes), [AWS](https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html)). | `managed-csi` (Azure compatible) |
| `pipelines.capabilities` | Add [demands/capabilities](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/demands?view=azure-devops&tabs=yaml) to the agent | `[]` |
| `pipelines.pat` | Personal Access Token (PAT) used by the agent to connect to the Azure DevOps server (both SaaS and self-hosted). | *None* |
| `pipelines.pool` | Agent pool to which the Agent should register. | *None* |
| `pipelines.timeout` | Time in seconds after a agent will be stopped, the same amount of time is applied as a timeout for the system to shut down. | `3600` (1 hour) |
| `pipelines.tmpdirSize` | Total size of the [standard `TMPDIR` directory](https://en.wikipedia.org/wiki/TMPDIR).  | `1Gi` |
| `pipelines.tmpdirType` | Disk type to attach to the [standard `TMPDIR` directory](https://en.wikipedia.org/wiki/TMPDIR). See your cloud provider for types ([Azure](https://learn.microsoft.com/en-us/azure/aks/concepts-storage#storage-classes), [AWS](https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html)). | `managed-csi` (Azure compatible) |
| `pipelines.url` | The Azure base URL for your organization | *None* |
| `podSecurityContext` | Security rules applied to the Pod ([more details](https://kubernetes.io/docs/concepts/security/pod-security-standards)). | `{}` |
| `replicaCount` | Default fixed amount of agents deployed. Those are not auto-scaled. | `3` |
| `resources` | Resource limits | `{ "resources": { "limits": { "cpu": 2, "memory": "4Gi" }, "requests": { "cpu": 1, "memory": "2Gi" } }}` |
| `securityContext` | Security rules applied to the container ([more details](https://kubernetes.io/docs/concepts/security/pod-security-standards)). | `{}` |
| `serviceAccount.create` | Create ServiceAccount | `true` |
| `serviceAccount.name` | ServiceAccount name | *Release name* |
| `tolerations` | Toleration labels for pod assignment. | `[]` |

## [Security](./SECURITY.md)

## Support

This project is open source and maintained by people like you. If you need help or found a bug, please feel free to open an issue on the [clemlesne/azure-pipelines-agent](https://github.com/clemlesne/azure-pipelines-agent) GitHub project.

## [Code of conduct](./CODE_OF_CONDUCT.md)

## [Authors](./AUTHORS.md)

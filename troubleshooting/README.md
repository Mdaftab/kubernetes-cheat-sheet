# Kubernetes Troubleshooting Guides

This directory contains organized troubleshooting guides for common Kubernetes issues.

## Categories

### [Pod Lifecycle Issues](./pod-lifecycle/)
Problems related to pod startup, initialization, and termination.
- [Pending Pods](./pod-lifecycle/pending.md) - Pods stuck in Pending state
- [Pod Initializing](./pod-lifecycle/podinitializing.md) - Pods stuck in PodInitializing state
- [Terminating Pods](./pod-lifecycle/terminating.md) - Pods stuck in Terminating state

### [Container Issues](./container-issues/)
Problems at the container runtime level.
- [CrashLoopBackOff](./container-issues/crashloopbackoff.md) - Containers repeatedly crashing
- [ContainerCannotRun](./container-issues/containercannotrun.md) - Containers failing to start
- [OOMKilled](./container-issues/oomkilled.md) - Containers terminated due to out of memory

### [Image Issues](./image-issues/)
Problems with container images and registries.
- [ImagePullBackOff](./image-issues/imagepullbackoff.md) - Kubernetes unable to pull container images
- [ErrImagePull](./image-issues/errimagepull.md) - Error during image pulling
- [ErrImageNeverPull](./image-issues/errimagenerverpull.md) - Image configured to never be pulled

### [Configuration Issues](./config-issues/)
Problems with Kubernetes resource configuration.
- [CreateContainerConfigError](./config-issues/createcontainerconfigerror.md) - Configuration errors preventing container creation
- [Evicted](./config-issues/evicted.md) - Pods evicted due to resource constraints
- [DeadlineExceeded](./config-issues/deadlineexceeded.md) - Operations timing out
- [BackOff](./config-issues/backoff.md) - General backoff errors

## Using This Guide

1. Identify the error you're experiencing in your Kubernetes cluster
2. Navigate to the corresponding category and guide
3. Follow the systematic troubleshooting approach
4. Execute the commands in your terminal, replacing placeholders with your specific values
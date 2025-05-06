# Container Issues Troubleshooting

This directory contains guides for troubleshooting container-specific issues in Kubernetes.

## Common Issues

### [CrashLoopBackOff](./crashloopbackoff.md)
Containers repeatedly crashing, with Kubernetes attempting to restart them on a backoff schedule.

### [ContainerCannotRun](./containercannotrun.md)
Containers failing to start due to misconfiguration, missing dependencies, or runtime issues.

### [OOMKilled](./oomkilled.md)
Containers terminated by Kubernetes due to exceeding their memory limits or node memory pressure.

## Related Resources

- [Kubernetes Container Lifecycle Hooks](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/)
- [Container Runtime Interface (CRI) Documentation](https://kubernetes.io/docs/concepts/architecture/cri/)
- [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
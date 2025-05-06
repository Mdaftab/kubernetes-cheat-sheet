# Concise CrashLoopBackOff Troubleshooting Guide

## Quick Command Reference

```bash
# Identify problematic pods
kubectl get pods -A | grep CrashLoopBackOff
kubectl get pods -n <namespace> | grep CrashLoopBackOff

# Get pod details and logs
kubectl describe pod <pod> -n <namespace>
kubectl logs <pod> -n <namespace>
kubectl logs <pod> -n <namespace> --previous
kubectl logs <pod> -c <container> -n <namespace>

# Check for common errors
kubectl logs <pod> -n <namespace> | grep -E "ERROR|FATAL|EXCEPTION"

# Resource usage and limits
kubectl get pod <pod> -n <namespace> -o jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}'
kubectl top pod <pod> -n <namespace>

# Check configurations
kubectl get pod <pod> -n <namespace> -o jsonpath='{.spec.containers[0].livenessProbe}'
kubectl get pod <pod> -n <namespace> -o jsonpath='{.spec.containers[0].image}'
kubectl get configmaps -n <namespace>
kubectl get secrets -n <namespace>

# Init container status
kubectl get pod <pod> -n <namespace> -o jsonpath='{.status.initContainerStatuses[*].state}'
kubectl logs <pod> -n <namespace> -c <init-container>

# Real-time debugging
kubectl debug -it <pod> -n <namespace> --image=busybox -- sh

# Quick fixes
kubectl edit deployment <deployment> -n <namespace>
kubectl set image deployment/<deployment> <container>=<new-image>:<tag> -n <namespace>
kubectl patch deployment <deployment> -n <namespace> -p '{"spec":{"template":{"spec":{"containers":[{"name":"<container>","livenessProbe":null}]}}}}'
kubectl rollout restart deployment <deployment> -n <namespace>
```

## Common Scenarios

1. **Application Error**: Check logs for error messages.
2. **Resource Constraints**: Verify OOM kills and resource usage.
3. **Liveness Probe**: Ensure probe configuration is correct.
4. **Invalid Image**: Confirm image name and tag are accurate.
5. **ConfigMap/Secret**: Check if required ConfigMaps/Secrets exist.
6. **Init Container**: Verify init container status and logs.

## Troubleshooting Steps

1. Identify the pod(s) in CrashLoopBackOff state.
2. Check pod details and recent events.
3. Analyze container logs (current and previous).
4. Verify resource usage and limits.
5. Check configurations (probes, images, ConfigMaps, Secrets).
6. Inspect init containers if present.
7. Use real-time debugging for complex issues.
8. Apply quick fixes if necessary, then address root cause.

Remember to replace `<pod>`, `<namespace>`, `<container>`, `<deployment>`, and other placeholders with actual values.

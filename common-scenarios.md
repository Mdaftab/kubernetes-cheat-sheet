# Common Kubernetes Scenarios and Solutions

This guide connects everyday Kubernetes issues with the appropriate troubleshooting resources in this repository.

## 1. Pod Starting but Never Ready

**Symptoms:**
- Pod is in Running state but readiness probe fails
- Service cannot route traffic to the pod
- Application appears to be running but is inaccessible

**Relevant Guides:**
- [CrashLoopBackOff](./troubleshooting/container-issues/crashloopbackoff.md) - If the container restarts repeatedly
- [Container Cannot Run](./troubleshooting/container-issues/containercannotrun.md) - If the container starts but exits

**Key Commands:**
```bash
# Check readiness probe configuration
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Readiness"

# Check pod logs for application startup issues
kubectl logs <pod-name> -n <namespace>

# Check if service is correctly selecting the pod
kubectl get endpoints <service-name> -n <namespace>
```

## 2. Deployment Rollout Stuck

**Symptoms:**
- New deployment version doesn't fully roll out
- Some old pods remain while new ones are created
- `kubectl rollout status` shows the deployment is not progressing

**Relevant Guides:**
- [Pod Initializing](./troubleshooting/pod-lifecycle/podinitializing.md) - If new pods are stuck in initialization
- [Pending Pods](./troubleshooting/pod-lifecycle/pending.md) - If new pods won't schedule

**Key Commands:**
```bash
# Check rollout status
kubectl rollout status deployment <deployment-name> -n <namespace>

# See detailed deployment conditions
kubectl describe deployment <deployment-name> -n <namespace>

# Check replica sets to see progression
kubectl get rs -n <namespace> -l app=<app-label>

# Inspect any pod disruption budgets that might be blocking
kubectl get pdb -n <namespace>
```

## 3. Node Running Out of Resources

**Symptoms:**
- Pods being evicted
- New pods stuck in pending state
- Node showing NotReady status intermittently

**Relevant Guides:**
- [OOMKilled](./troubleshooting/container-issues/oomkilled.md) - For memory-related failures
- [Evicted](./troubleshooting/config-issues/evicted.md) - For pods being evicted due to resource pressure
- [Pending Pods](./troubleshooting/pod-lifecycle/pending.md) - For scheduling failures

**Key Commands:**
```bash
# Check node resource usage
kubectl top nodes

# Look for resource pressure conditions
kubectl describe node <node-name> | grep -A 5 "Conditions:"

# See pods consumption on the node
kubectl top pods --sort-by=memory -A | grep <node-name>

# Check node allocatable resources
kubectl describe node <node-name> | grep -A 8 "Allocatable:"
```

## 4. Service Not Routing Traffic Correctly

**Symptoms:**
- Applications can't connect to services
- Intermittent connection failures
- DNS resolution works but connections time out

**Relevant Guides:**
- [Multi-Resource Issues](./troubleshooting/multi-resource-troubleshooting.md) - For cross-namespace communication

**Key Commands:**
```bash
# Verify service has endpoints
kubectl get endpoints <service-name> -n <namespace>

# Check if pods match service selector
kubectl get pods -n <namespace> -l <service-selector> 

# Debug with test pod
kubectl run -it --rm debug-pod --image=nicolaka/netshoot -n <namespace> -- bash

# Test service DNS resolution
kubectl run -it --rm debug-pod --image=busybox -n <namespace> -- nslookup <service-name>.<namespace>.svc.cluster.local
```

## 5. Image Pull Failures in CI/CD Pipeline

**Symptoms:**
- Deployments work locally but fail in the CI environment
- ImagePullBackOff errors
- Pods stuck in ContainerCreating state

**Relevant Guides:**
- [ImagePullBackOff](./troubleshooting/image-issues/imagepullbackoff.md)
- [ErrImagePull](./troubleshooting/image-issues/errimagepull.md)

**Key Commands:**
```bash
# Check image pull secrets
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.imagePullSecrets}'

# Verify image name and tag
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].image}'

# Check registry access from a node
kubectl run test-pull --rm -it --image=<problematic-image> -- /bin/sh

# Create or update image pull secret
kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email> -n <namespace>
```

## 6. ConfigMap or Secret Changes Not Reflected in Pods

**Symptoms:**
- Updated ConfigMaps/Secrets don't affect running applications
- Application still uses old configuration after updates
- No errors in logs, but configuration changes aren't applied

**Relevant Guides:**
- [CreateContainerConfigError](./troubleshooting/config-issues/createcontainerconfigerror.md)

**Key Commands:**
```bash
# Check if ConfigMap/Secret is mounted as volume or env var
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Environment\|Mounts"

# Look at ConfigMap/Secret content
kubectl get configmap <configmap-name> -n <namespace> -o yaml
kubectl get secret <secret-name> -n <namespace> -o jsonpath='{.data}' | jq -r 'map_values(@base64d)'

# Restart deployment to pick up changes (for env vars)
kubectl rollout restart deployment <deployment-name> -n <namespace>

# Look for subPath volume mounts which don't update automatically
kubectl get pod <pod-name> -n <namespace> -o json | jq '.spec.volumes[] | select(.configMap != null or .secret != null) | .configMap.items, .secret.items'
```

## 7. Persistent Volume Claims Stuck in Pending

**Symptoms:**
- PVCs remain in Pending state
- Pods that use the PVCs get stuck in ContainerCreating
- StorageClass issues or provisioner problems

**Relevant Guides:**
- [Pending Pods](./troubleshooting/pod-lifecycle/pending.md) - If pods are waiting for volumes
- [Multi-Resource Issues](./troubleshooting/multi-resource-troubleshooting.md) - Section on StatefulSet scaling with PVCs

**Key Commands:**
```bash
# Check PVC status
kubectl describe pvc <pvc-name> -n <namespace>

# Verify StorageClass exists and is default
kubectl get storageclass

# Check storage provisioner pods
kubectl get pods -n kube-system | grep provisioner

# Look for storage-related events
kubectl get events -n <namespace> --field-selector involvedObject.kind=PersistentVolumeClaim
```

## 8. Cluster Networking Issues

**Symptoms:**
- Pods can't communicate across namespaces
- Intermittent connection timeouts
- DNS resolution problems
- Services not reachable

**Relevant Guides:**
- [Multi-Resource Issues](./troubleshooting/multi-resource-troubleshooting.md) - Section on Cross-Namespace Service Communication

**Key Commands:**
```bash
# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Test DNS resolution from a pod
kubectl run -it --rm dns-test --image=busybox -n <namespace> -- nslookup kubernetes.default

# Check Network Policies
kubectl get networkpolicies --all-namespaces

# Debug with a network diagnostic pod
kubectl run -it --rm net-debug --image=nicolaka/netshoot -n <namespace> -- bash
```

## 9. Pods Terminating but Never Completing

**Symptoms:**
- Pods stuck in Terminating state
- Node issues or finalizer problems
- kubectl delete pod doesn't complete

**Relevant Guides:**
- [Terminating Pods](./troubleshooting/pod-lifecycle/terminating.md)

**Key Commands:**
```bash
# Check if pod has finalizers
kubectl get pod <pod-name> -n <namespace> -o json | jq '.metadata.finalizers'

# Check for stuck volumeattachments
kubectl get volumeattachment | grep <pv-name>

# Force delete the pod (use with caution)
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0

# Check node status if the pod's node is having issues
kubectl describe node <node-name>
```

## 10. Ingress Issues and External Access Problems

**Symptoms:**
- Services accessible within cluster but not externally
- Ingress controller logs show errors
- Certificate issues or routing problems

**Relevant Commands:**
```bash
# Check Ingress resources
kubectl get ingress -A

# Inspect Ingress controller logs
kubectl logs -n <ingress-namespace> -l app=nginx-ingress-controller

# Verify TLS certificates
kubectl get secret <tls-secret> -n <namespace> -o yaml

# Test connectivity from inside a pod
kubectl run -it --rm curl-test --image=curlimages/curl -n <namespace> -- curl -v <service-url>

# Check ingress annotations
kubectl get ingress <ingress-name> -n <namespace> -o yaml | grep -A 50 annotations
```

Remember to replace placeholders like `<pod-name>`, `<namespace>`, and `<service-name>` with your actual values when using these commands.

Use our [scripts](./scripts/) directory for more automated troubleshooting:
- [pod-inspector.sh](./scripts/pod-inspector.sh) - For detailed pod analysis
- [cluster-health.sh](./scripts/cluster-health.sh) - For overall cluster health checks
- [network-tester.sh](./scripts/network-tester.sh) - For testing service connectivity
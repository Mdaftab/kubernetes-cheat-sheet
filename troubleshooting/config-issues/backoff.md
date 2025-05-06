# Kubernetes BackOff Error Troubleshooting Commands

BackOff error occurs when a container repeatedly fails to start, often due to application crashes, resource constraints, or misconfigurations, causing Kubernetes to delay restart attempts.

```bash
# Identify pods in BackOff state
kubectl get pods -A | grep -E '(BackOff|CrashLoopBackOff)'
kubectl get pods -n <namespace> | grep -E '(BackOff|CrashLoopBackOff)'

# Get detailed information about the pod
kubectl describe pod <pod-name> -n <namespace>

# View recent events related to the pod
kubectl get events -n <namespace> | grep <pod-name>

# Check container logs (including previous instances)
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous

# For multi-container pods, specify the container
kubectl logs <pod-name> -c <container-name> -n <namespace>

# View pod's resource requests and limits
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].resources}'

# Check current resource usage
kubectl top pod <pod-name> -n <namespace>

# View node resource usage
kubectl top nodes

# Check if the container's command is correct
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].command}'

# Verify environment variables
kubectl set env pod/<pod-name> -n <namespace> --list

# Check for any init containers
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.initContainers[*].name}'

# Inspect liveness and readiness probes
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].livenessProbe}'
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].readinessProbe}'

# Check ConfigMaps used by the pod
kubectl get configmap -n <namespace>
kubectl describe configmap <configmap-name> -n <namespace>

# Verify Secrets used by the pod
kubectl get secret -n <namespace>
kubectl describe secret <secret-name> -n <namespace>

# Check PersistentVolumeClaims
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>

# Verify node status
kubectl describe node <node-name>

# Check for any taints on the node
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Inspect pod security context
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.securityContext}'

# Check for any network policies
kubectl get networkpolicies -n <namespace>

# Verify service account permissions
kubectl get serviceaccount <serviceaccount-name> -n <namespace> -o yaml

# Check for any pod disruption budgets
kubectl get poddisruptionbudget -n <namespace>

# Inspect kubelet logs on the node
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kubelet -o jsonpath='{.items[0].metadata.name}')

# Check for any custom resource definitions used
kubectl get crd

# Verify RBAC permissions
kubectl auth can-i --list --as=system:serviceaccount:<namespace>:<serviceaccount>

# Check for any pod security policies
kubectl get psp
kubectl describe psp <psp-name>

# Inspect admission webhooks
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Check container image and pull policy
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].image}'
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].imagePullPolicy}'

# Verify image pull secrets
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.imagePullSecrets[*].name}'

# Check for any finalizers preventing termination
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.metadata.finalizers}'

# Inspect node pressure conditions
kubectl describe node <node-name> | grep -A 5 Conditions:

# Check for any preemption events
kubectl get events -A | grep Preempted

# Verify container runtime status (requires node access)
ssh <node-ip> 'sudo systemctl status containerd'  # For containerd
ssh <node-ip> 'sudo systemctl status docker'  # For Docker

# Analyze cgroup settings (requires node access)
ssh <node-ip> 'sudo cat /sys/fs/cgroup/memory/memory.limit_in_bytes'

# Check for out of memory events (requires node access)
ssh <node-ip> 'dmesg | grep -i "out of memory"'

# Restart the deployment to force new pod creation
kubectl rollout restart deployment <deployment-name> -n <namespace>

# Scale down and up the deployment
kubectl scale deployment <deployment-name> -n <namespace> --replicas=0
kubectl scale deployment <deployment-name> -n <namespace> --replicas=1

# Force delete the pod (use with caution)
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0

# Update container resources if needed
kubectl set resources deployment <deployment-name> -c=<container-name> --limits=cpu=500m,memory=512Mi --requests=cpu=250m,memory=256Mi -n <namespace>

# Check for and remove any crashloop backoff pods
kubectl get pods -A | grep CrashLoopBackOff | awk '{print $2 " -n " $1}' | xargs -L1 kubectl delete pod
```

Replace `<pod-name>`, `<namespace>`, `<container-name>`, `<configmap-name>`, `<secret-name>`, `<pvc-name>`, `<node-name>`, `<serviceaccount-name>`, `<psp-name>`, `<deployment-name>`, and other placeholders with actual values.

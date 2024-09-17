# Kubernetes OOMKilled Troubleshooting Commands

OOMKilled error occurs when a container in a pod attempts to use more memory than its limit, or if the node runs out of memory, causing the kernel to terminate the container.

```bash
# Identify OOMKilled pods
kubectl get pods -A | grep OOMKilled
kubectl get pods -n <namespace> | grep OOMKilled

# Get detailed information about the OOMKilled pod
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Last State"

# Check memory requests and limits for the pod
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].resources}'

# View current memory usage of pods
kubectl top pods -n <namespace>

# Check node memory capacity and allocatable resources
kubectl describe nodes | grep -A 5 "Capacity\|Allocatable"

# View memory usage of nodes
kubectl top nodes

# Check for any memory-related events
kubectl get events -n <namespace> | grep -i "memory"

# Analyze container logs before OOMKilled
kubectl logs <pod-name> -n <namespace> --previous

# Check if the pod is part of a deployment and view its configuration
kubectl get deployment -n <namespace> | grep <deployment-name>
kubectl describe deployment <deployment-name> -n <namespace>

# View memory limits in LimitRange (if set)
kubectl get limitrange -n <namespace>
kubectl describe limitrange <limitrange-name> -n <namespace>

# Check ResourceQuota for the namespace
kubectl get resourcequota -n <namespace>
kubectl describe resourcequota <quota-name> -n <namespace>

# Inspect node pressure conditions
kubectl describe node <node-name> | grep -A 5 Conditions:

# Check kubelet logs for OOM events
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kubelet -o jsonpath='{.items[0].metadata.name}') | grep -i "oom"

# View cgroup memory limits (requires node access)
ssh <node-ip> 'cat /sys/fs/cgroup/memory/kubepods/pod*/memory.limit_in_bytes'

# Check system logs for OOM events (requires node access)
ssh <node-ip> 'dmesg | grep -i "out of memory"'

# Analyze memory usage trends with metrics-server (if installed)
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/namespaces/<namespace>/pods/<pod-name>" | jq .

# Check for memory-hungry processes inside the container (before OOMKilled)
kubectl exec <pod-name> -n <namespace> -- top -o -n 1

# View horizontal pod autoscaler configurations (if used)
kubectl get hpa -n <namespace>
kubectl describe hpa <hpa-name> -n <namespace>

# Check if pod security policies are restricting memory
kubectl get psp
kubectl describe psp <psp-name>

# Analyze quality of service (QoS) class of the pod
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.status.qosClass}'

# Check for any init containers that might be memory-intensive
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Init Containers:"

# View pod disruption budget (if set) that might prevent scaling
kubectl get pdb -n <namespace>
kubectl describe pdb <pdb-name> -n <namespace>

# Check for any failing liveness or readiness probes that might restart pods
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Liveness:\|Readiness:"

# Analyze cluster autoscaler logs for scaling issues (if used)
kubectl logs -n kube-system -l app=cluster-autoscaler

# Check for any memory-related Pod Topology Spread Constraints
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.topologySpreadConstraints}'

# Verify if there are any taints preventing scheduling on nodes with more resources
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Inspect container runtime status and logs
kubectl get nodes -o wide
ssh <node-ip> 'sudo systemctl status containerd && sudo journalctl -u containerd'

# Force delete the OOMKilled pod to reschedule it
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0

# Update deployment to increase memory limit
kubectl set resources deployment <deployment-name> -n <namespace> --limits=memory=<new-limit>

# Restart the deployment to apply changes
kubectl rollout restart deployment <deployment-name> -n <namespace>
```

Replace `<pod-name>`, `<namespace>`, `<deployment-name>`, `<node-name>`, `<limitrange-name>`, `<quota-name>`, `<hpa-name>`, `<psp-name>`, `<pdb-name>`, and other placeholders with actual values.

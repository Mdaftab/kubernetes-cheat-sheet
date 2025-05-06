# Kubernetes Evicted Pod Troubleshooting Commands

Evicted pod error occurs when Kubernetes forcibly terminates pods due to node resource constraints (CPU, memory, or disk), node failures, or policy violations.

```bash
# Identify Evicted pods
kubectl get pods -A | grep Evicted
kubectl get pods -n <namespace> | grep Evicted

# Get details of Evicted pods
kubectl describe pod <pod-name> -n <namespace> | grep -A 5 "Status:"

# List all Evicted pods with their eviction reasons
kubectl get pods -A | grep Evicted | awk '{print $1, $2}' | xargs -L1 kubectl describe pod -n | grep -E "^Name:|Reason:"

# Check node resource usage
kubectl top nodes
kubectl describe nodes | grep -A 5 "Allocated resources"

# Identify nodes under pressure
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Check specific node conditions
kubectl describe node <node-name> | grep -A 5 Conditions:

# View cluster events related to evictions
kubectl get events -A | grep Evicted

# Check pod resource requests and limits
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].resources}'

# Analyze pod logs before eviction
kubectl logs <pod-name> -n <namespace> --previous

# Check persistent volume claims
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>

# Verify storage class provisioner status
kubectl get pods -n kube-system | grep provisioner

# Inspect node disk pressure
kubectl describe node <node-name> | grep "DiskPressure"

# Check cluster-wide resource quotas
kubectl describe resourcequotas -A

# View namespace resource quotas
kubectl describe resourcequotas -n <namespace>

# Check limit ranges in the namespace
kubectl get limitranges -n <namespace>
kubectl describe limitranges <limitrange-name> -n <namespace>

# Analyze kubelet logs for eviction events
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kubelet -o jsonpath='{.items[0].metadata.name}') | grep -i evict

# Check for out of memory events
dmesg | grep -i "out of memory"

# Inspect node's available disk space
kubectl debug node/<node-name> -it --image=ubuntu -- df -h

# Check container runtime status
kubectl get nodes -o wide
ssh <node-ip> 'sudo systemctl status kubelet'

# Verify pod security policies
kubectl get psp
kubectl describe psp <psp-name>

# Check for any taints on nodes
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Inspect node allocatable resources
kubectl get nodes -o jsonpath='{.items[*].status.allocatable}'

# View pod quality of service class
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.status.qosClass}'

# Check for pods consuming excessive resources
kubectl top pods -A --sort-by=cpu
kubectl top pods -A --sort-by=memory

# Analyze cgroup settings (requires node access)
ssh <node-ip> 'sudo cat /sys/fs/cgroup/memory/memory.limit_in_bytes'

# Check for any problematic Init containers
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Init Containers:"

# Verify node capacity vs allocatable resources
kubectl get nodes -o custom-columns=NAME:.metadata.name,CAPACITY:.status.capacity.memory,ALLOCATABLE:.status.allocatable.memory

# Check for any failing liveness or readiness probes
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Liveness:"
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Readiness:"

# Inspect pod disruption budgets
kubectl get poddisruptionbudgets -A
kubectl describe poddisruptionbudget <pdb-name> -n <namespace>

# Check for any failing operators or controllers
kubectl get pods -n kube-system
kubectl logs -n kube-system <controller-pod-name>

# Verify cluster autoscaler logs (if used)
kubectl logs -n kube-system -l app=cluster-autoscaler

# Analyze etcd health and performance
kubectl -n kube-system exec -it etcd-<node-name> -- etcdctl endpoint health
kubectl -n kube-system exec -it etcd-<node-name> -- etcdctl endpoint status -w table

# Force delete Evicted pods
kubectl get pods -A | grep Evicted | awk '{print $2 " -n " $1}' | xargs -L1 kubectl delete pod

# Recreate pods from deployments
kubectl get deployment -n <namespace> | awk '{print $1}' | xargs -L1 kubectl rollout restart deployment -n <namespace>
```

Replace `<pod-name>`, `<namespace>`, `<node-name>`, `<pvc-name>`, `<limitrange-name>`, `<psp-name>`, `<pdb-name>`, and other placeholders with actual values.

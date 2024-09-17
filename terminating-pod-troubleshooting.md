# Kubernetes Terminating Pod Troubleshooting Commands

Terminating pod status persists when a pod is unable to complete its shutdown process, often due to stuck finalizers, unresponsive processes, or resource issues preventing graceful termination.

```bash
# Identify Terminating pods
kubectl get pods -A | grep Terminating
kubectl get pods -n <namespace> | grep Terminating

# Get detailed information about the Terminating pod
kubectl describe pod <pod-name> -n <namespace>

# Check events related to the Terminating pod
kubectl get events -n <namespace> | grep <pod-name>

# View pod's finalizers
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.metadata.finalizers}'

# Check if containers are still running in the pod
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.status.containerStatuses[*].state}'

# View logs of the terminating pod
kubectl logs <pod-name> -n <namespace>

# Check for any volumes attached to the pod
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.volumes}'

# Verify PersistentVolumeClaim status
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>

# Check for any network policies affecting the pod
kubectl get networkpolicies -n <namespace>

# Verify if there are any pod disruption budgets
kubectl get poddisruptionbudget -n <namespace>

# Check node status where the pod is running
kubectl describe node <node-name>

# View kubelet logs for termination issues
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kubelet -o jsonpath='{.items[0].metadata.name}')

# Check for any stuck jobs or cronjobs
kubectl get jobs -n <namespace>
kubectl get cronjobs -n <namespace>

# Verify if there are any lingering endpoints
kubectl get endpoints -n <namespace> | grep <pod-ip>

# Check for any preStop hooks in the pod spec
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].lifecycle.preStop}'

# Verify if there are any pending operations in etcd
kubectl -n kube-system exec -it etcd-<node-name> -- etcdctl endpoint status --cluster -w table

# Check for any custom resource definitions that might be blocking deletion
kubectl get crd
kubectl get <custom-resource-name> -n <namespace>

# Verify if there are any admission webhooks interfering
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Check for any finalizers in owning resources (e.g., ReplicaSet)
kubectl get rs -n <namespace> -o jsonpath='{.items[*].metadata.finalizers}'

# View any container runtime issues (requires node access)
ssh <node-ip> 'sudo crictl ps | grep <pod-name>'
ssh <node-ip> 'sudo crictl logs <container-id>'

# Check for any stuck terminating namespaces
kubectl get namespaces | grep Terminating

# Verify if there are any lingering iptables rules (requires node access)
ssh <node-ip> 'sudo iptables-save | grep <pod-ip>'

# Check for any orphaned containerd processes (requires node access)
ssh <node-ip> 'sudo ps aux | grep containerd-shim'

# Verify if kubelet is responsive
kubectl get --raw /healthz/kubelet

# Check for any pending CSI operations
kubectl get volumeattachments

# Force delete the Terminating pod (use with caution)
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0

# If force delete doesn't work, try removing finalizers
kubectl patch pod <pod-name> -n <namespace> -p '{"metadata":{"finalizers":null}}' --type=merge

# Check for any stuck Terminating namespaces and force delete them
kubectl get ns | grep Terminating | awk '{print $1}' | xargs -I{} kubectl delete ns {} --force --grace-period=0

# Restart kubelet on the node (requires node access)
ssh <node-ip> 'sudo systemctl restart kubelet'

# Cordon the problematic node
kubectl cordon <node-name>

# Drain the node (will evict all pods)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Uncordon the node after issues are resolved
kubectl uncordon <node-name>
```

Replace `<pod-name>`, `<namespace>`, `<node-name>`, `<pvc-name>`, `<pod-ip>`, `<container-id>`, `<custom-resource-name>`, and other placeholders with actual values.

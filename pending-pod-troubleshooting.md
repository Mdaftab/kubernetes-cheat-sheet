# Kubernetes Pending Pod Troubleshooting Commands

Pending pod status occurs when Kubernetes is unable to schedule a pod onto a node, often due to insufficient resources, node selector mismatches, or policy constraints.

```bash
# Identify Pending pods
kubectl get pods -A | grep Pending
kubectl get pods -n <namespace> | grep Pending

# Get detailed information about the Pending pod
kubectl describe pod <pod-name> -n <namespace>

# Check events related to the Pending pod
kubectl get events -n <namespace> | grep <pod-name>

# View node resource usage
kubectl top nodes

# Check available resources on nodes
kubectl describe nodes | grep -A 5 "Allocated resources"

# Verify pod resource requests
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].resources.requests}'

# Check node selectors on the pod
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.nodeSelector}'

# List node labels
kubectl get nodes --show-labels

# Check for taints on nodes
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Verify pod tolerations
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.tolerations}'

# Check PersistentVolumeClaim status if used
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>

# Verify StorageClass provisioner status
kubectl get storageclass
kubectl get pods -n kube-system | grep provisioner

# Check if there are enough resources in the namespace
kubectl describe resourcequota -n <namespace>

# Verify LimitRange settings
kubectl get limitrange -n <namespace>
kubectl describe limitrange <limitrange-name> -n <namespace>

# Check for any PodDisruptionBudgets affecting scheduling
kubectl get poddisruptionbudget -n <namespace>
kubectl describe poddisruptionbudget <pdb-name> -n <namespace>

# Verify network policies that might affect pod scheduling
kubectl get networkpolicies -n <namespace>

# Check for pod affinity/anti-affinity rules
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.affinity}'

# Verify if the pod security policy allows scheduling
kubectl get psp
kubectl describe psp <psp-name>

# Check kubelet logs for scheduling issues
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kubelet -o jsonpath='{.items[0].metadata.name}')

# Verify kube-scheduler is running
kubectl get pods -n kube-system | grep kube-scheduler

# Check kube-scheduler logs
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kube-scheduler -o jsonpath='{.items[0].metadata.name}')

# Verify if there are any init containers causing delays
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Init Containers:"

# Check for any failing readiness gates
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.readinessGates}'

# Verify cluster autoscaler status (if used)
kubectl get deployments -n kube-system | grep cluster-autoscaler
kubectl logs -n kube-system -l app=cluster-autoscaler

# Check for any priority classes affecting scheduling
kubectl get priorityclass
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.priorityClassName}'

# Verify if there are any pod topology spread constraints
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.topologySpreadConstraints}'

# Check if the service account exists and has proper permissions
kubectl get serviceaccount -n <namespace>
kubectl get rolebindings -n <namespace>
kubectl get clusterrolebindings

# Verify if there are any admission webhooks interfering
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Check for any custom schedulers
kubectl get pods <pod-name> -n <namespace> -o jsonpath='{.spec.schedulerName}'

# Verify node conditions
kubectl describe nodes | grep -i "condition"

# Check for any preemption events
kubectl get events -A | grep Preempted

# Force delete the Pending pod (if stuck)
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0

# Recreate the pod (if part of a deployment)
kubectl rollout restart deployment <deployment-name> -n <namespace>
```

Replace `<pod-name>`, `<namespace>`, `<pvc-name>`, `<limitrange-name>`, `<pdb-name>`, `<psp-name>`, `<deployment-name>`, and other placeholders with actual values.

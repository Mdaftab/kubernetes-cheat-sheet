# Kubernetes PodInitializing Troubleshooting Commands

PodInitializing status occurs during the pod startup process, typically when init containers are running or volumes are being attached. It becomes problematic if it persists longer than expected, often due to init container failures, volume mount issues, or resource constraints.

```bash
# Identify pods stuck in PodInitializing state
kubectl get pods -A | grep PodInitializing
kubectl get pods -n <namespace> | grep PodInitializing

# Get detailed information about the pod
kubectl describe pod <pod-name> -n <namespace>

# View recent events related to the pod
kubectl get events -n <namespace> | grep <pod-name>

# Check status of init containers
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.status.initContainerStatuses[*].state}'

# View logs of specific init container
kubectl logs <pod-name> -c <init-container-name> -n <namespace>

# Check resource requests and limits for init containers
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.initContainers[*].resources}'

# View volume information for the pod
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.volumes}'

# Check PersistentVolumeClaim status
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>

# Verify StorageClass provisioner status
kubectl get storageclass
kubectl get pods -n kube-system | grep provisioner

# Check node resource usage
kubectl top nodes

# View node conditions
kubectl describe node <node-name> | grep Conditions: -A 5

# Check for any taints on nodes
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Verify pod security context
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.securityContext}'

# Check for any node selector requirements
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.nodeSelector}'

# View pod affinity/anti-affinity rules
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.affinity}'

# Check for any toleration settings
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.tolerations}'

# Verify image pull policy and secrets
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].imagePullPolicy}'
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.imagePullSecrets}'

# Check ConfigMaps used by the pod
kubectl get configmap -n <namespace>
kubectl describe configmap <configmap-name> -n <namespace>

# Verify Secrets used by the pod
kubectl get secret -n <namespace>
kubectl describe secret <secret-name> -n <namespace>

# Inspect service account permissions
kubectl get serviceaccount <serviceaccount-name> -n <namespace> -o yaml

# Check for any network policies
kubectl get networkpolicies -n <namespace>

# View any custom priorityClass assigned
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.priorityClassName}'

# Check for any pod security policies
kubectl get psp
kubectl describe psp <psp-name>

# Inspect admission webhooks
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Check kubelet logs on the node
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kubelet -o jsonpath='{.items[0].metadata.name}')

# Verify container runtime status (requires node access)
ssh <node-ip> 'sudo systemctl status containerd'  # For containerd
ssh <node-ip> 'sudo systemctl status docker'  # For Docker

# Check for any custom resource definitions used
kubectl get crd

# Verify RBAC permissions
kubectl auth can-i --list --as=system:serviceaccount:<namespace>:<serviceaccount>

# Inspect any finalizers on the pod
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.metadata.finalizers}'

# Check for any preemption events
kubectl get events -A | grep Preempted

# View detailed scheduling information
kubectl get events --sort-by=.metadata.creationTimestamp | grep <pod-name>

# Check for any init container crashes
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.status.initContainerStatuses[*].lastState.terminated.reason}'

# Verify if volumes are mounted correctly
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].volumeMounts}'

# Check for any pod topology spread constraints
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.topologySpreadConstraints}'

# Inspect node allocatable resources
kubectl describe node <node-name> | grep Allocatable: -A 5

# Check for any resource quotas in the namespace
kubectl get resourcequota -n <namespace>
kubectl describe resourcequota <quota-name> -n <namespace>

# Verify limit ranges in the namespace
kubectl get limitrange -n <namespace>
kubectl describe limitrange <limitrange-name> -n <namespace>

# Force delete the pod (use with caution)
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0

# Recreate the pod (if part of a deployment)
kubectl rollout restart deployment <deployment-name> -n <namespace>

# Scale down and up the deployment
kubectl scale deployment <deployment-name> -n <namespace> --replicas=0
kubectl scale deployment <deployment-name> -n <namespace> --replicas=1
```

Replace `<pod-name>`, `<namespace>`, `<init-container-name>`, `<pvc-name>`, `<node-name>`, `<configmap-name>`, `<secret-name>`, `<serviceaccount-name>`, `<psp-name>`, `<quota-name>`, `<limitrange-name>`, `<deployment-name>`, and other placeholders with actual values.

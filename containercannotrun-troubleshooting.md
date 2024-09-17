# Kubernetes ContainerCannotRun Error Troubleshooting Commands

ContainerCannotRun error occurs when Kubernetes is unable to start a container, often due to misconfigurations, permission issues, resource constraints, or problems with the container image or runtime.

```bash
# Identify pods with ContainerCannotRun error
kubectl get pods -A | grep ContainerCannotRun
kubectl get pods -n <namespace> | grep ContainerCannotRun

# Get detailed information about the pod
kubectl describe pod <pod-name> -n <namespace>

# View recent events related to the pod
kubectl get events -n <namespace> | grep <pod-name>

# Check container logs (if available)
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous

# For multi-container pods, specify the container
kubectl logs <pod-name> -c <container-name> -n <namespace>

# Verify container image and pull policy
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].image}'
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].imagePullPolicy}'

# Check image pull secrets
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.imagePullSecrets[*].name}'

# Inspect container command and args
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].command}'
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].args}'

# View container environment variables
kubectl set env pod/<pod-name> -n <namespace> --list

# Check resource requests and limits
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].resources}'

# Verify node resource availability
kubectl describe node <node-name> | grep -A 5 "Allocated resources"

# Check for any init containers
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.initContainers[*].name}'

# Inspect security context
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.securityContext}'
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].securityContext}'

# Check volume mounts
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.volumes}'
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].volumeMounts}'

# Verify PersistentVolumeClaim status
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>

# Check ConfigMaps used by the pod
kubectl get configmap -n <namespace>
kubectl describe configmap <configmap-name> -n <namespace>

# Verify Secrets used by the pod
kubectl get secret -n <namespace>
kubectl describe secret <secret-name> -n <namespace>

# Inspect node conditions
kubectl describe node <node-name> | grep -A 5 Conditions:

# Check for any taints on the node
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Verify pod security policies
kubectl get psp
kubectl describe psp <psp-name>

# Check network policies
kubectl get networkpolicies -n <namespace>

# Inspect service account permissions
kubectl get serviceaccount <serviceaccount-name> -n <namespace> -o yaml

# Verify RBAC permissions
kubectl auth can-i --list --as=system:serviceaccount:<namespace>:<serviceaccount>

# Check admission webhooks
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Inspect kubelet logs
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kubelet -o jsonpath='{.items[0].metadata.name}')

# Check container runtime status (requires node access)
ssh <node-ip> 'sudo systemctl status containerd'  # For containerd
ssh <node-ip> 'sudo systemctl status docker'  # For Docker

# Verify SELinux context (if applicable, requires node access)
ssh <node-ip> 'sudo chcon -Rt svirt_sandbox_file_t /path/to/volume'

# Check AppArmor profile (if applicable, requires node access)
ssh <node-ip> 'cat /proc/1/attr/current'

# Inspect cgroup settings (requires node access)
ssh <node-ip> 'sudo cat /sys/fs/cgroup/memory/memory.limit_in_bytes'

# Check for any custom resource definitions used
kubectl get crd

# Verify limit ranges in the namespace
kubectl get limitrange -n <namespace>
kubectl describe limitrange <limitrange-name> -n <namespace>

# Check resource quotas
kubectl get resourcequota -n <namespace>
kubectl describe resourcequota <quota-name> -n <namespace>

# Inspect any pod disruption budgets
kubectl get poddisruptionbudget -n <namespace>

# Check for preemption events
kubectl get events -A | grep Preempted

# Verify if there are any finalizers preventing termination
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.metadata.finalizers}'

# Check for any topology spread constraints
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.topologySpreadConstraints}'

# Inspect node allocatable resources
kubectl get nodes -o custom-columns=NAME:.metadata.name,ALLOCATABLE:.status.allocatable

# Force delete the pod (use with caution)
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0

# Recreate the pod (if part of a deployment)
kubectl rollout restart deployment <deployment-name> -n <namespace>

# Update container resources if needed
kubectl set resources deployment <deployment-name> -c=<container-name> --limits=cpu=500m,memory=512Mi --requests=cpu=250m,memory=256Mi -n <namespace>

# Check for and remove any containers that cannot run
kubectl get pods -A | grep ContainerCannotRun | awk '{print $2 " -n " $1}' | xargs -L1 kubectl delete pod
```

Replace `<pod-name>`, `<namespace>`, `<container-name>`, `<node-name>`, `<pvc-name>`, `<configmap-name>`, `<secret-name>`, `<serviceaccount-name>`, `<psp-name>`, `<limitrange-name>`, `<quota-name>`, `<deployment-name>`, and other placeholders with actual values.

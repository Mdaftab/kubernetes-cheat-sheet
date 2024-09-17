# Kubernetes CreateContainerConfigError Troubleshooting Commands

```bash
# Identify pods with CreateContainerConfigError
kubectl get pods -A | grep CreateContainerConfigError
kubectl get pods -n <namespace> | grep CreateContainerConfigError

# Get detailed pod information
kubectl describe pod <pod-name> -n <namespace>
kubectl get pod <pod-name> -n <namespace> -o yaml

# Check specific container status
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.status.containerStatuses[*].state.waiting.reason}'

# Inspect container configuration
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*]}'

# Check for configuration in deployments
kubectl get deployment <deployment-name> -n <namespace> -o yaml

# Verify ConfigMaps used by the pod
kubectl get configmap -n <namespace>
kubectl describe configmap <configmap-name> -n <namespace>

# Check Secrets used by the pod
kubectl get secret -n <namespace>
kubectl describe secret <secret-name> -n <namespace>

# Inspect environment variables
kubectl set env pod/<pod-name> -n <namespace> --list

# Check for volume mounts
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].volumeMounts}'

# Verify PersistentVolumeClaims
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>

# Inspect init containers
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.initContainers[*]}'

# Check resource requirements
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].resources}'

# Verify node affinity and anti-affinity rules
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.affinity}'

# Check tolerations
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.tolerations}'

# Inspect security context
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.securityContext}'

# Verify service account
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.serviceAccountName}'

# Check for any admission webhooks
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Analyze events related to the pod
kubectl get events -n <namespace> --field-selector involvedObject.name=<pod-name>

# Inspect kubelet logs
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kubelet -o jsonpath='{.items[0].metadata.name}')

# Check for any custom resource definitions used
kubectl get crd
kubectl describe crd <crd-name>

# Verify RBAC permissions
kubectl auth can-i --list --as=system:serviceaccount:<namespace>:<serviceaccount>

# Check for any pod security policies
kubectl get psp
kubectl describe psp <psp-name>

# Inspect network policies
kubectl get networkpolicies -n <namespace>
kubectl describe networkpolicy <policy-name> -n <namespace>

# Verify container runtime status
kubectl get nodes -o wide
ssh <node-ip> 'sudo systemctl status containerd'  # For containerd
ssh <node-ip> 'sudo systemctl status docker'  # For Docker

# Check for any resource quotas
kubectl get resourcequota -n <namespace>
kubectl describe resourcequota <quota-name> -n <namespace>

# Verify limit ranges
kubectl get limitrange -n <namespace>
kubectl describe limitrange <limitrange-name> -n <namespace>

# Inspect container image details
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].image}'

# Check for any projected volumes
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.volumes[*].projected}'

# Verify any custom commands or arguments
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].command}'
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].args}'

# Force delete and recreate the pod
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0
kubectl scale deployment <deployment-name> -n <namespace> --replicas=0
kubectl scale deployment <deployment-name> -n <namespace> --replicas=1

# Check for any finalizers preventing deletion
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.metadata.finalizers}'
```

Replace `<pod-name>`, `<namespace>`, `<deployment-name>`, `<configmap-name>`, `<secret-name>`, `<pvc-name>`, `<crd-name>`, `<serviceaccount>`, `<psp-name>`, `<policy-name>`, `<quota-name>`, `<limitrange-name>`, and other placeholders with actual values.

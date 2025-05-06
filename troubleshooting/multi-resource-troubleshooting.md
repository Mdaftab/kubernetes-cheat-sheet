# Multi-Resource Kubernetes Troubleshooting

This guide covers troubleshooting complex scenarios involving multiple Kubernetes resources.

## StatefulSet Scaling with PVCs

### Overview
StatefulSets have complex behaviors when scaling up or down, particularly regarding PersistentVolumeClaims (PVCs). Common issues include stuck pods, volume attachment failures, and data inconsistency.

### Quick Command Reference
```bash
# Verify StatefulSet status
kubectl get statefulset <statefulset-name> -n <namespace>
kubectl describe statefulset <statefulset-name> -n <namespace>

# Check PVC status
kubectl get pvc -n <namespace> -l app=<app-label>
kubectl describe pvc <pvc-name> -n <namespace>

# Validate PV status
kubectl get pv | grep <pvc-name>
kubectl describe pv <pv-name>

# Check storage class parameters
kubectl get storageclass <storage-class-name> -o yaml

# Review events related to the StatefulSet
kubectl get events -n <namespace> --field-selector involvedObject.kind=StatefulSet,involvedObject.name=<statefulset-name>

# Check pod status and ordering
kubectl get pods -n <namespace> -l app=<app-label> --sort-by=.metadata.name

# Verify volume attachments
kubectl get volumeattachments | grep <pv-name>
```

### Common Causes
1. **Storage Provisioner Issues**: The storage provisioner can't create/delete volumes as requested.
2. **Volume Attachment Timeouts**: Cloud provider volume operations exceeding timeout limits.
3. **Zone/Region Mismatches**: Pod scheduled in a zone where PVC/PV is unavailable.
4. **Retention Policy Problems**: PVs with Retain policy not being properly recycled.

### Advanced Diagnostics
```bash
# Debug StatefulSet controller issues
kubectl logs -n kube-system -l component=kube-controller-manager --tail=100 | grep statefulset

# Check for stuck volume operations in cloud provider
kubectl logs -n kube-system -l k8s-app=kube-controller-manager | grep "attachdetach"

# Detect stale volume attachments
kubectl get nodes -o json | jq '.items[].status.volumesAttached'

# Simulate StatefulSet scaling via dry-run
kubectl scale statefulset <statefulset-name> --replicas=<count> -n <namespace> --dry-run=server

# Test storage provisioner manually
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
  namespace: <namespace>
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: <storage-class-name>
EOF
```

## GitOps Deployment Troubleshooting (ArgoCD)

### Overview
GitOps tools like ArgoCD can face sync issues, failed health checks, or webhook failures.

### Quick Command Reference
```bash
# Check ArgoCD application status
argocd app get <app-name>
kubectl get applications.argoproj.io -n argocd <app-name> -o yaml

# View sync status and events
argocd app history <app-name>
kubectl describe applications.argoproj.io -n argocd <app-name>

# Examine resource discrepancies
argocd app diff <app-name> --local <path-to-manifests>

# Check controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# Verify webhook delivery
kubectl get secret -n <namespace> <webhook-secret-name> -o yaml
kubectl logs -n <namespace> -l app.kubernetes.io/name=<webhook-receiver> --tail=100

# Debug sync operation
argocd app sync <app-name> --prune --debug
```

## Cross-Namespace Service Communication

### Overview
Services across namespaces can have connectivity issues due to network policies, DNS problems, or service mesh configurations.

### Quick Command Reference
```bash
# Test cross-namespace DNS resolution
kubectl run tmp-dns-test -n <source-namespace> --image=busybox --restart=Never --rm -it -- nslookup <service-name>.<destination-namespace>.svc.cluster.local

# Check network policies
kubectl get networkpolicies -n <destination-namespace>
kubectl describe networkpolicy <policy-name> -n <destination-namespace>

# Verify service endpoints
kubectl get endpoints <service-name> -n <destination-namespace>
kubectl get pods -n <destination-namespace> -l <service-selector>

# Test connectivity
kubectl run tmp-net-test -n <source-namespace> --image=busybox --restart=Never --rm -it -- wget -T 5 <service-name>.<destination-namespace>.svc.cluster.local:<port>

# Check for service mesh sidecars
kubectl get pods -n <destination-namespace> -l <service-selector> -o jsonpath='{.items[*].spec.containers[*].name}'

# Analyze service mesh traffic rules (Istio)
kubectl get virtualservices -n <destination-namespace>
kubectl get destinationrules -n <destination-namespace>
istioctl analyze -n <destination-namespace>

# Verify CoreDNS configuration
kubectl get configmap -n kube-system coredns -o yaml
kubectl logs -n kube-system -l k8s-app=kube-dns
```

## Admission Controller Issues

### Overview
Admission controllers like OPA/Gatekeeper, PodSecurityPolicy, or custom webhooks can block resource creation with limited feedback.

### Quick Command Reference
```bash
# List enabled admission controllers
kubectl exec -it -n kube-system $(kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath='{.items[0].metadata.name}') -- kube-apiserver --help | grep enable-admission-plugins

# Check validation webhook configurations
kubectl get validatingwebhookconfigurations
kubectl describe validatingwebhookconfigurations <webhook-name>

# Examine mutating webhook configurations
kubectl get mutatingwebhookconfigurations
kubectl describe mutatingwebhookconfigurations <webhook-name>

# Get webhook service logs
kubectl logs -n <webhook-namespace> -l <webhook-service-selector>

# Test resource creation with dry run
kubectl apply -f <resource-file.yaml> --dry-run=server

# Debug with API server audit logs
kubectl logs -n kube-system -l component=kube-apiserver | grep -E "admission|validat|mutat" | tail -20

# Check OPA/Gatekeeper constraints
kubectl get constraints
kubectl describe constraint <constraint-name>
kubectl get constrainttemplates
```

Remember to replace placeholders (`<statefulset-name>`, `<namespace>`, etc.) with actual values from your environment.
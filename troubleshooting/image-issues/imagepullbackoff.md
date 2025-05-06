# Kubernetes ImagePullBackOff Troubleshooting Commands

```bash
# Identify pods with ImagePullBackOff
kubectl get pods -A | grep ImagePullBackOff
kubectl get pods -n <namespace> | grep ImagePullBackOff

# Get detailed pod information
kubectl describe pod <pod-name> -n <namespace>
kubectl get pod <pod-name> -n <namespace> -o yaml

# Check image details
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].image}'
kubectl get deployment <deployment-name> -n <namespace> -o jsonpath='{.spec.template.spec.containers[*].image}'

# Verify image pull secrets
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.imagePullSecrets[*].name}'
kubectl get secret <secret-name> -n <namespace> -o jsonpath='{.data.\.dockerconfigjson}' | base64 --decode

# Check node status and capacity
kubectl describe node <node-name> | grep -A 5 "Allocated resources"
kubectl get nodes -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}'

# Verify network connectivity from a node
kubectl run test-net --rm -it --image=busybox -- /bin/sh -c "ping -c 4 google.com"

# Test image pull manually
kubectl run test-pull --rm -it --image=<problematic-image> -- /bin/sh

# Check for registry authentication issues
kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email> -n <namespace>
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}' -n <namespace>

# Verify pod security policies
kubectl get psp
kubectl auth can-i use podsecuritypolicy/<psp-name> --as=system:serviceaccount:<namespace>:default

# Check for available disk space on nodes
kubectl debug node/<node-name> -it --image=busybox -- df -h

# Analyze kubelet logs for pull errors
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kubelet -o jsonpath='{.items[0].metadata.name}')

# Restart problematic deployments
kubectl rollout restart deployment <deployment-name> -n <namespace>

# Force delete stuck pods (use cautiously)
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0

# Update image in deployment
kubectl set image deployment/<deployment-name> <container-name>=<new-image>:<tag> -n <namespace>

# Scale deployment to force new pod creation
kubectl scale deployment <deployment-name> --replicas=0 -n <namespace>
kubectl scale deployment <deployment-name> --replicas=1 -n <namespace>

# Check for cluster-wide pull rate limits
kubectl describe nodes | grep "docker pull"

# Verify container runtime status
kubectl get nodes -o wide
ssh <node-ip> 'sudo systemctl status docker'  # For Docker runtime
ssh <node-ip> 'sudo crictl info'  # For containerd

# Test image pull using crictl (if using containerd)
ssh <node-ip> 'sudo crictl pull <image-name>:<tag>'

# Check for image vulnerabilities (requires Trivy)
trivy image <image-name>:<tag>

# Monitor image registry health (if self-hosted)
curl -I https://<registry-url>/v2/

# Verify network policies aren't blocking registry access
kubectl get networkpolicies -A
kubectl describe networkpolicy <policy-name> -n <namespace>

# Check for storage issues affecting image storage
kubectl describe pv | grep -E "Capacity|Used"
```

Replace `<pod-name>`, `<namespace>`, `<deployment-name>`, `<node-name>`, `<image-name>`, `<tag>`, and other placeholders with actual values.

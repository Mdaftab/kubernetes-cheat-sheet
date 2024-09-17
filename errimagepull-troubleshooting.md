# Kubernetes ErrImagePull Troubleshooting Commands

```bash
# Identify pods with ErrImagePull
kubectl get pods -A | grep ErrImagePull
kubectl get pods -n <namespace> | grep ErrImagePull

# Get detailed pod information
kubectl describe pod <pod-name> -n <namespace>
kubectl get pod <pod-name> -n <namespace> -o yaml

# Check specific container status
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.status.containerStatuses[*].state.waiting.reason}'

# Verify image name and tag
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].image}'

# Check image pull policy
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].imagePullPolicy}'

# Inspect image pull secrets
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.imagePullSecrets[*].name}'
kubectl get secret <secret-name> -n <namespace> -o yaml

# Decode docker config secret
kubectl get secret <secret-name> -n <namespace> -o jsonpath='{.data.\.dockerconfigjson}' | base64 --decode

# Test image pull manually
kubectl run test-pull --rm -it --image=<problematic-image> -- /bin/sh

# Check node status
kubectl describe node <node-name> | grep -A 5 "Conditions"

# Verify network connectivity
kubectl run test-net --rm -it --image=busybox -- /bin/sh -c "ping -c 4 <registry-hostname>"

# Check DNS resolution
kubectl run test-dns --rm -it --image=busybox -- /bin/sh -c "nslookup <registry-hostname>"

# Inspect kubelet logs
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kubelet -o jsonpath='{.items[0].metadata.name}')

# Check for registry authentication issues
kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email> -n <namespace>
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}' -n <namespace>

# Verify image exists in registry
curl -k -u <username>:<password> https://<registry-url>/v2/<repository>/manifests/<tag>

# Check for rate limiting
kubectl describe nodes | grep "Error: ImagePullBackOff"

# Analyze container runtime logs (for containerd)
kubectl debug node/<node-name> -it --image=ubuntu
crictl logs $(crictl ps -a | grep <pod-name> | awk '{print $1}')

# Verify storage capacity for images
kubectl describe node <node-name> | grep -A 5 "Allocated resources"

# Check for network policies blocking registry access
kubectl get networkpolicies -A
kubectl describe networkpolicy <policy-name> -n <namespace>

# Inspect registry health (if self-hosted)
curl -I https://<registry-url>/v2/

# Test pull with crictl (if using containerd)
ssh <node-ip> 'sudo crictl pull <image-name>:<tag>'

# Verify container runtime status
ssh <node-ip> 'sudo systemctl status containerd'  # For containerd
ssh <node-ip> 'sudo systemctl status docker'  # For Docker

# Check for image vulnerabilities (requires Trivy)
trivy image <image-name>:<tag>

# Force delete stuck pods (use cautiously)
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0

# Update image in deployment
kubectl set image deployment/<deployment-name> <container-name>=<new-image>:<tag> -n <namespace>

# Restart problematic deployments
kubectl rollout restart deployment <deployment-name> -n <namespace>

# Scale deployment to force new pod creation
kubectl scale deployment <deployment-name> --replicas=0 -n <namespace>
kubectl scale deployment <deployment-name> --replicas=1 -n <namespace>

# Check pod security context
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.securityContext}'

# Verify cluster-wide pull rate limits
kubectl describe nodes | grep "Error: ImagePullBackOff"
```

Replace `<pod-name>`, `<namespace>`, `<deployment-name>`, `<node-name>`, `<image-name>`, `<tag>`, `<registry-hostname>`, and other placeholders with actual values.

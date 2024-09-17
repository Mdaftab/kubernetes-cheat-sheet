# Kubernetes ErrImageNeverPull Troubleshooting Commands

```bash
# Identify pods with ErrImageNeverPull
kubectl get pods -A | grep ErrImageNeverPull
kubectl get pods -n <namespace> | grep ErrImageNeverPull

# Get detailed pod information
kubectl describe pod <pod-name> -n <namespace>
kubectl get pod <pod-name> -n <namespace> -o yaml

# Check image pull policy
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].imagePullPolicy}'

# Verify image name and tag
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].image}'

# Check if the image exists locally on the node
kubectl debug node/<node-name> -it --image=ubuntu
crictl images | grep <image-name>

# Inspect deployment configuration
kubectl get deployment <deployment-name> -n <namespace> -o yaml | grep -A 5 imagePullPolicy

# Check if the image is available in the specified registry
curl -k -u <username>:<password> https://<registry-url>/v2/<repository>/manifests/<tag>

# Verify node status and conditions
kubectl describe node <node-name> | grep -A 5 "Conditions"

# Check container runtime status
ssh <node-ip> 'sudo systemctl status containerd'  # For containerd
ssh <node-ip> 'sudo systemctl status docker'  # For Docker

# Analyze kubelet logs for pull errors
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kubelet -o jsonpath='{.items[0].metadata.name}')

# Inspect image pull secrets
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.imagePullSecrets[*].name}'
kubectl get secret <secret-name> -n <namespace> -o yaml

# Check pod security context
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.securityContext}'

# Verify service account permissions
kubectl get serviceaccount <service-account-name> -n <namespace> -o yaml

# Test image pull manually with different pull policies
kubectl run test-always --rm -it --image=<image-name> --image-pull-policy=Always -- /bin/sh
kubectl run test-ifnotpresent --rm -it --image=<image-name> --image-pull-policy=IfNotPresent -- /bin/sh
kubectl run test-never --rm -it --image=<image-name> --image-pull-policy=Never -- /bin/sh

# Check for any taints on the node that might prevent scheduling
kubectl describe node <node-name> | grep Taints

# Verify cluster-wide image pull policy (if set)
kubectl get kubeadmconfig -n kube-system -o yaml | grep imageRepository

# Inspect container runtime configuration
ssh <node-ip> 'sudo cat /etc/containerd/config.toml | grep pull_options'  # For containerd
ssh <node-ip> 'sudo cat /etc/docker/daemon.json'  # For Docker

# Check for any admission webhooks that might modify pod configurations
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Analyze events related to the pod
kubectl get events -n <namespace> --field-selector involvedObject.name=<pod-name>

# Force delete the pod and recreate it
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0
kubectl scale deployment <deployment-name> -n <namespace> --replicas=0
kubectl scale deployment <deployment-name> -n <namespace> --replicas=1

# Update image pull policy in the deployment
kubectl patch deployment <deployment-name> -n <namespace> -p '{"spec":{"template":{"spec":{"containers":[{"name":"<container-name>","imagePullPolicy":"Always"}]}}}}'

# Check for any network policies that might block access to the registry
kubectl get networkpolicies -A
kubectl describe networkpolicy <policy-name> -n <namespace>

# Verify if the image is present in all nodes (for multi-node clusters)
for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  echo "Checking $node"
  kubectl debug node/$node -it --image=ubuntu -- crictl images | grep <image-name>
done
```

Replace `<pod-name>`, `<namespace>`, `<deployment-name>`, `<node-name>`, `<image-name>`, `<tag>`, `<registry-url>`, and other placeholders with actual values.

# Kubernetes DeadlineExceeded Error Troubleshooting Commands

DeadlineExceeded error occurs when a job or pod fails to complete within its specified time limit, often due to resource constraints, misconfigured deadlines, or long-running processes.

```bash
# Identify pods with DeadlineExceeded status
kubectl get pods -A | grep DeadlineExceeded
kubectl get pods -n <namespace> | grep DeadlineExceeded

# Get detailed information about the affected pod
kubectl describe pod <pod-name> -n <namespace>

# Check events related to the DeadlineExceeded pod
kubectl get events -n <namespace> | grep <pod-name>

# View logs of the failed pod
kubectl logs <pod-name> -n <namespace>

# Check job details if the pod is part of a job
kubectl get job <job-name> -n <namespace>
kubectl describe job <job-name> -n <namespace>

# View job's activeDeadlineSeconds setting
kubectl get job <job-name> -n <namespace> -o jsonpath='{.spec.activeDeadlineSeconds}'

# Check CronJob configuration if applicable
kubectl get cronjob <cronjob-name> -n <namespace>
kubectl describe cronjob <cronjob-name> -n <namespace>

# View CronJob's startingDeadlineSeconds setting
kubectl get cronjob <cronjob-name> -n <namespace> -o jsonpath='{.spec.startingDeadlineSeconds}'

# Check resource requests and limits for the pod
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].resources}'

# View current resource usage of pods
kubectl top pods -n <namespace>

# Check node resource usage
kubectl top nodes

# Verify if there are enough resources in the namespace
kubectl describe resourcequota -n <namespace>

# Check LimitRange settings
kubectl get limitrange -n <namespace>
kubectl describe limitrange <limitrange-name> -n <namespace>

# View pod's quality of service class
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.status.qosClass}'

# Check for any init containers that might be delaying main container startup
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Init Containers:"

# Verify if there are any readiness probes causing delays
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].readinessProbe}'

# Check for any liveness probes that might be restarting the container
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].livenessProbe}'

# View pod disruption budget (if set) that might prevent termination
kubectl get pdb -n <namespace>
kubectl describe pdb <pdb-name> -n <namespace>

# Check for any node affinity rules that might delay scheduling
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.affinity}'

# Verify if there are any taints preventing scheduling on certain nodes
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Check for any pod security policies restricting execution
kubectl get psp
kubectl describe psp <psp-name>

# View any custom priorityClass assigned to the pod
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.priorityClassName}'

# Check for any network policies that might be interfering
kubectl get networkpolicies -n <namespace>

# Verify if there are any admission webhooks causing delays
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Check kubelet logs for any scheduling or execution issues
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kubelet -o jsonpath='{.items[0].metadata.name}')

# View kube-scheduler logs
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kube-scheduler -o jsonpath='{.items[0].metadata.name}')

# Check for any PersistentVolumeClaims that might be delaying pod startup
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>

# Verify StorageClass provisioner status
kubectl get storageclass
kubectl get pods -n kube-system | grep provisioner

# Check for any finalizers that might delay pod termination
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.metadata.finalizers}'

# Analyze pod topology spread constraints
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.topologySpreadConstraints}'

# Check for any preemption events
kubectl get events -A | grep Preempted

# View details of the pod's service account
kubectl get serviceaccount <serviceaccount-name> -n <namespace> -o yaml

# Increase job timeout (if appropriate)
kubectl patch job <job-name> -n <namespace> -p '{"spec":{"activeDeadlineSeconds": 600}}'

# Increase CronJob timeout (if appropriate)
kubectl patch cronjob <cronjob-name> -n <namespace> -p '{"spec":{"startingDeadlineSeconds": 300}}'

# Delete the failed job and recreate it
kubectl delete job <job-name> -n <namespace>
kubectl create job --from=cronjob/<cronjob-name> <job-name> -n <namespace>

# Force delete a stuck pod (use with caution)
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0
```

Replace `<pod-name>`, `<namespace>`, `<job-name>`, `<cronjob-name>`, `<limitrange-name>`, `<pdb-name>`, `<psp-name>`, `<pvc-name>`, `<serviceaccount-name>`, and other placeholders with actual values.

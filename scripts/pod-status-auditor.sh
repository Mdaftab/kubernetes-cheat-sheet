#!/bin/bash
# pod-status-auditor.sh - Audit all problematic pods across namespaces

status_type=${1:-all}  # all, CrashLoopBackOff, Pending, OOMKilled, Evicted, ImagePullBackOff, Terminating

case $status_type in
  all)
    echo "🔎 Finding all problematic pods across all namespaces..."
    problem_pods=$(kubectl get pods -A | grep -v "Running\|Completed" | grep -v "NAME")
    ;;
  CrashLoopBackOff)
    echo "🔎 Finding all CrashLoopBackOff pods..."
    problem_pods=$(kubectl get pods -A | grep "CrashLoopBackOff")
    ;;
  Pending)
    echo "🔎 Finding all Pending pods..."
    problem_pods=$(kubectl get pods -A | grep "Pending")
    ;;
  OOMKilled)
    echo "🔎 Finding all OOMKilled pods..."
    problem_pods=$(kubectl get pods -A | grep "OOMKilled")
    ;;
  Evicted)
    echo "🔎 Finding all Evicted pods..."
    problem_pods=$(kubectl get pods -A | grep "Evicted")
    ;;
  ImagePullBackOff)
    echo "🔎 Finding all ImagePullBackOff pods..."
    problem_pods=$(kubectl get pods -A | grep "ImagePullBackOff\|ErrImagePull")
    ;;
  Terminating)
    echo "🔎 Finding all Terminating pods..."
    problem_pods=$(kubectl get pods -A | grep "Terminating")
    ;;
  *)
    echo "❌ Unknown status type. Use one of: all, CrashLoopBackOff, Pending, OOMKilled, Evicted, ImagePullBackOff, Terminating"
    exit 1
    ;;
esac

if [ -z "$problem_pods" ]; then
  echo "✅ No pods found with status: $status_type"
  exit 0
fi

echo "$problem_pods" | while read line; do
  namespace=$(echo $line | awk '{print $1}')
  pod_name=$(echo $line | awk '{print $2}')
  status=$(echo $line | awk '{print $4}')
  
  echo "===================================================="
  echo "🔍 Pod: $pod_name in Namespace: $namespace with Status: $status"
  
  echo "📋 Pod Events:"
  kubectl get events -n $namespace | grep $pod_name
  
  case $status in
    *"CrashLoopBackOff"*)
      echo "📝 Container Logs:"
      kubectl logs $pod_name -n $namespace --previous 2>/dev/null || kubectl logs $pod_name -n $namespace
      echo "🔄 Restart Count: $(kubectl get pod $pod_name -n $namespace -o jsonpath='{.status.containerStatuses[0].restartCount}')"
      ;;
    *"Pending"*)
      echo "⏳ Scheduling Information:"
      kubectl describe pod $pod_name -n $namespace | grep -A 10 "Events:"
      ;;
    *"OOMKilled"*)
      echo "💾 Memory Requests/Limits:"
      kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.containers[*].resources}'
      echo "📝 Previous Container Logs:"
      kubectl logs $pod_name -n $namespace --previous 2>/dev/null || echo "No previous logs available"
      ;;
    *"Evicted"*)
      echo "⚠️ Eviction Reason:"
      kubectl describe pod $pod_name -n $namespace | grep -A 3 "Status:"
      ;;
    *"ImagePullBackOff"*|*"ErrImagePull"*)
      echo "🖼️ Image Details:"
      kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.containers[*].image}'
      echo -e "\n🔑 Image Pull Secrets:"
      kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.imagePullSecrets}'
      ;;
    *"Terminating"*)
      echo "⏱️ Finalizers:"
      kubectl get pod $pod_name -n $namespace -o jsonpath='{.metadata.finalizers}'
      ;;
  esac
  
  echo "===================================================="
done
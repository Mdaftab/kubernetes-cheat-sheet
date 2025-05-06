#!/bin/bash
# pod-inspector.sh - Comprehensive pod status troubleshooting tool

pod_name=$1
namespace=${2:-default}

if [ -z "$pod_name" ]; then
  echo "Usage: $0 <pod_name> [namespace]"
  echo "Example: $0 my-pod-xyz123 kube-system"
  exit 1
fi

echo "🔍 Investigating pod: $pod_name in namespace: $namespace"

echo "📋 Basic Pod Information:"
kubectl describe pod $pod_name -n $namespace

echo "📜 Recent Events:"
kubectl get events -n $namespace | grep $pod_name

echo "📊 Resource Usage:"
kubectl top pod $pod_name -n $namespace 2>/dev/null || echo "Metrics server not available"

echo "📝 Container Logs:"
containers=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.containers[*].name}')
for container in $containers; do
  echo "📄 Logs for container: $container"
  kubectl logs $pod_name -c $container -n $namespace
  echo "📄 Previous logs for container: $container (if available)"
  kubectl logs $pod_name -c $container -n $namespace --previous 2>/dev/null || echo "No previous logs available"
done

echo "🔄 Init Container Status:"
init_containers=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.initContainers[*].name}' 2>/dev/null)
if [ -n "$init_containers" ]; then
  for init_container in $init_containers; do
    echo "📄 Init Container: $init_container Status:"
    kubectl get pod $pod_name -n $namespace -o jsonpath="{.status.initContainerStatuses[?(@.name==\"$init_container\")].state}"
    echo -e "\n📄 Logs for init container: $init_container"
    kubectl logs $pod_name -c $init_container -n $namespace 2>/dev/null || echo "No logs available"
  done
else
  echo "No init containers found"
fi

echo "⚙️ Pod Configuration Details:"
echo "Image: $(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.containers[*].image}')"
echo "Resource Requests/Limits: $(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.containers[*].resources}')"
echo "Volume Mounts: $(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.volumes}')"
echo "Node: $(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.nodeName}')"
echo "Service Account: $(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.serviceAccountName}')"
echo "QoS Class: $(kubectl get pod $pod_name -n $namespace -o jsonpath='{.status.qosClass}')"
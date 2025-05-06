#!/bin/bash
# network-tester.sh - Test network connectivity inside the cluster

namespace=${1:-default}
target_service=${2:-"kubernetes.default.svc"}
target_port=${3:-443}

echo "🌐 Kubernetes Network Connectivity Tester"
echo "Target: $target_service:$target_port in namespace: $namespace"

echo "🔍 Creating test pod in namespace $namespace..."
kubectl run network-tester --image=nicolaka/netshoot -n $namespace --restart=Never -i --rm --timeout=60s -- bash -c "
echo '🔌 DNS Resolution Test:'
nslookup $target_service

echo '🔄 Connectivity Test:'
nc -zv $target_service $target_port

echo '🕸️ Traceroute Test:'
traceroute $target_service

echo '🌐 HTTP Request Test (if applicable):'
curl -v --max-time 5 https://$target_service:$target_port 2>&1 || echo 'Not applicable or failed'

echo '📊 Network Policy Check:'
kubectl get networkpolicies -n $namespace 2>/dev/null || echo 'No network policies found'
"

echo "✅ Network test completed"
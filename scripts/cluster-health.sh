#!/bin/bash
# cluster-health.sh - Overall cluster health assessment tool

echo "🏥 Kubernetes Cluster Health Check"

echo "🔄 API Server Status:"
kubectl get --raw /healthz

echo "🔄 Component Status:"
kubectl get componentstatuses 2>/dev/null || echo "Component status API deprecated in your version"

echo "🖥️ Node Status:"
kubectl get nodes -o wide

echo "📊 Node Resource Usage:"
kubectl top nodes 2>/dev/null || echo "Metrics server not available"

echo "🔍 Node Conditions:"
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints,CONDITIONS:.status.conditions

echo "👷 System Pods Health:"
kubectl get pods -n kube-system

echo "🚨 Failed Pods Across All Namespaces:"
kubectl get pods -A | grep -v "Running\|Completed" | grep -v "NAME"

echo "⚠️ Recent Events:"
kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -n 20

echo "💾 Persistent Volume Status:"
kubectl get pv

echo "📈 Resource Quotas:"
kubectl get resourcequotas -A

echo "⛓️ Limit Ranges:"
kubectl get limitranges -A

echo "🔒 Network Policies:"
kubectl get networkpolicies -A

echo "🔎 Deployment Statuses:"
kubectl get deployments -A
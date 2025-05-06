#!/bin/bash
# log-analyzer.sh - Find and analyze patterns in pod logs

pod_pattern=$1
namespace=${2:-default}
time_duration=${3:-"1h"}

if [ -z "$pod_pattern" ]; then
  echo "Usage: $0 <pod_pattern> [namespace] [time_duration]"
  echo "Example: $0 frontend default 2h"
  exit 1
fi

echo "📊 Kubernetes Log Pattern Analyzer"
echo "Analyzing logs for pods matching: $pod_pattern in namespace: $namespace for the last $time_duration"

# Get matching pods
matching_pods=$(kubectl get pods -n $namespace | grep "$pod_pattern" | awk '{print $1}')

if [ -z "$matching_pods" ]; then
  echo "❌ No pods found matching pattern: $pod_pattern"
  exit 1
fi

temp_log_file=$(mktemp)
for pod in $matching_pods; do
  echo "📝 Collecting logs from pod: $pod"
  kubectl logs --since=$time_duration $pod -n $namespace >> $temp_log_file 2>/dev/null
done

echo "📊 Log Analysis Results:"

echo "🔺 Top Error Messages:"
grep -i "error\|exception\|fail\|fatal" $temp_log_file | sort | uniq -c | sort -nr | head -10

echo "⚠️ Top Warning Messages:"
grep -i "warn\|warning" $temp_log_file | sort | uniq -c | sort -nr | head -10

echo "⏱️ Slow Operations (taking more than 1 second):"
grep -i -E "took [1-9][0-9]{3,}|took [0-9]+\.[0-9]+ seconds|latency [1-9][0-9]{3,}" $temp_log_file | sort | uniq -c | sort -nr | head -10

echo "🔁 Frequent Operations:"
grep -i -E "request|query|fetch|load|save|create|update|delete" $temp_log_file | sort | uniq -c | sort -nr | head -10

echo "🔢 Numeric Patterns (numbers that might indicate issues):"
grep -E "[0-9]+(ms|s|m|h)|\b[0-9]{3,}\b" $temp_log_file | sort | uniq -c | sort -nr | head -10

# Cleanup
rm $temp_log_file
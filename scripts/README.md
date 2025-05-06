# Kubernetes Troubleshooting Scripts

This directory contains practical scripts to help Kubernetes administrators and DevOps engineers diagnose and resolve issues quickly.

## Available Scripts

### 1. Pod Inspector (`pod-inspector.sh`)
Performs a comprehensive analysis of a specific pod, displaying all relevant information in one view.

```bash
./pod-inspector.sh <pod-name> [namespace]
```

Features:
- Shows pod details, events, and resource usage
- Displays logs for all containers and init containers
- Shows pod configuration details and status

### 2. Cluster Health Checker (`cluster-health.sh`)
Provides a complete health assessment of your Kubernetes cluster.

```bash
./cluster-health.sh
```

Features:
- Checks API server and component status
- Displays node conditions and resource usage
- Lists failed pods across all namespaces
- Shows recent events and resource statuses

### 3. Pod Status Auditor (`pod-status-auditor.sh`)
Finds and analyzes problematic pods across all namespaces.

```bash
./pod-status-auditor.sh [status-type]
```

Status types: `all`, `CrashLoopBackOff`, `Pending`, `OOMKilled`, `Evicted`, `ImagePullBackOff`, `Terminating`

Features:
- Identifies pods with specific error states
- Provides targeted diagnostics based on the error type
- Shows relevant logs, events, and configuration issues

### 4. Network Tester (`network-tester.sh`)
Tests network connectivity between services in your cluster.

```bash
./network-tester.sh [namespace] [target-service] [target-port]
```

Features:
- Performs DNS resolution tests
- Checks connectivity to the target service
- Runs traceroute and HTTP tests when applicable
- Identifies network policies that might affect connectivity

### 5. Log Analyzer (`log-analyzer.sh`)
Analyzes logs from multiple pods to identify patterns and issues.

```bash
./log-analyzer.sh <pod-pattern> [namespace] [time-duration]
```

Features:
- Collects and analyzes logs from matching pods
- Identifies common error and warning patterns
- Highlights slow operations and performance issues
- Detects frequent operations and potential bottlenecks

## Usage Tips

1. Make scripts executable with `chmod +x script-name.sh`
2. Run scripts from the command line with appropriate parameters
3. Redirect output to a file for later analysis: `./script-name.sh > output.txt`
4. Consider adding these scripts to your PATH for easier access

## Requirements

- kubectl configured with appropriate access to your cluster
- bash shell environment
- Common utilities (grep, awk, etc.)
- For network-tester.sh: ability to create temporary pods in the target namespace
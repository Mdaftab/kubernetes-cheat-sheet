# Kubernetes Troubleshooting Command Sets

![BUILT BY](https://img.shields.io/badge/BUILT%20BY-DevOps%20Engineers-brightgreen)
![BUILT WITH](https://img.shields.io/badge/BUILT%20WITH-kubectl-ff69b4)
![MADE WITH](https://img.shields.io/badge/MADE%20WITH-Kubernetes-blue)

![contributors](https://img.shields.io/badge/contributors-repo%20not%20found-orange)
![issues](https://img.shields.io/badge/issues-repo%20not%20found-orange)
![forks](https://img.shields.io/badge/forks-repo%20not%20found-orange)
![stars](https://img.shields.io/badge/stars-repo%20not%20found-orange)
![license](https://img.shields.io/badge/license-repo%20not%20found-orange)

🚀 Blast through Kubernetes issues with lightning speed! This project contains expert-crafted troubleshooting guides for common Kubernetes errors and problematic pod states. Designed for DevOps engineers and SREs who need to diagnose and resolve issues faster than you can say "kubectl"!

## 🎯 Why This Repo?

- 🔍 Comprehensive guides for common K8s headaches
- ⚡ Quick-copy commands for rapid troubleshooting
- 🧠 Explanations that even your coffee-deprived brain can understand
- 🛠 Battle-tested by engineers in the trenches

## Table of Contents

### [Pod Lifecycle Issues](./troubleshooting/pod-lifecycle/)
- [Pending Pods](./troubleshooting/pod-lifecycle/pending.md)
- [Pod Initializing](./troubleshooting/pod-lifecycle/podinitializing.md)
- [Terminating Pods](./troubleshooting/pod-lifecycle/terminating.md)

### [Container Issues](./troubleshooting/container-issues/)
- [CrashLoopBackOff](./troubleshooting/container-issues/crashloopbackoff.md)
- [ContainerCannotRun](./troubleshooting/container-issues/containercannotrun.md)
- [OOMKilled](./troubleshooting/container-issues/oomkilled.md)

### [Image Issues](./troubleshooting/image-issues/)
- [ImagePullBackOff](./troubleshooting/image-issues/imagepullbackoff.md)
- [ErrImagePull](./troubleshooting/image-issues/errimagepull.md)
- [ErrImageNeverPull](./troubleshooting/image-issues/errimagenerverpull.md)

### [Configuration Issues](./troubleshooting/config-issues/)
- [CreateContainerConfigError](./troubleshooting/config-issues/createcontainerconfigerror.md)
- [Evicted](./troubleshooting/config-issues/evicted.md)
- [DeadlineExceeded](./troubleshooting/config-issues/deadlineexceeded.md)
- [BackOff](./troubleshooting/config-issues/backoff.md)

### [Advanced Troubleshooting](./troubleshooting/)
- [Multi-Resource Issues](./troubleshooting/multi-resource-troubleshooting.md)

## How to Use

1. **Identify** the error you're experiencing in your Kubernetes cluster.
2. **Navigate** to the corresponding guide in this repository.
3. **Read** the brief explanation to understand common causes of the issue.
4. **Copy** the relevant commands from the guide.
5. **Execute** the commands in your terminal, replacing placeholders with your specific values.
6. **Follow** the systematic troubleshooting approach provided in each guide.

## Best Practices

- Always **test commands** in a non-production environment before applying them to critical systems.
- Ensure you have the necessary **permissions** in your Kubernetes cluster before executing commands.
- Some commands may require direct **node access**; verify your access levels before attempting these.
- **Familiarize** yourself with the commands in a test environment before using them in production.

## Repository Structure

```
kubernetes-cheat-sheet/
├── troubleshooting/              # Main troubleshooting content
│   ├── pod-lifecycle/            # Pod lifecycle issues
│   ├── container-issues/         # Container runtime problems
│   ├── image-issues/             # Image pull and registry issues
│   ├── config-issues/            # Configuration related problems
│   ├── networking/               # Network-related troubleshooting
│   └── storage/                  # Persistent storage issues
├── templates/                    # Document templates for consistency
└── scripts/                      # Validation and helper scripts
```

## Contributing

We welcome contributions to enhance these troubleshooting guides. If you have additional commands or improvements:

1. **Fork** the repository
2. **Create** a new branch for your changes
3. **Use** the template in `templates/troubleshooting-template.md` for new guides
4. **Validate** your changes with `scripts/validate-format.sh`
5. **Submit** a pull request with a description of your changes

Please ensure your contributions maintain the existing format and provide clear explanations for any new commands.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

These troubleshooting guides are provided as-is, without warranty of any kind. Always test commands in a safe environment before applying them to production systems.

Happy troubleshooting!
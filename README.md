# CloudDeployment

This repository contains Helm charts and deployment manifests for the main project.

## Repository Structure

```
CloudDeployment/
├── webapp/          # Helm chart for the web application
└── docs/            # Additional documentation
```

## Charts

### webapp

A production-ready Helm chart for deploying a simple web application on Kubernetes.

**Features:**
- Configurable Deployment with rolling update strategy
- Kubernetes Service (ClusterIP / NodePort / LoadBalancer)
- Optional Ingress with TLS support
- Optional Horizontal Pod Autoscaler (HPA)
- ServiceAccount with fine-grained RBAC support
- ConfigMap-backed environment variable injection
- Liveness and readiness health probes

See [webapp/README.md](webapp/README.md) for full documentation and configuration reference.

## Prerequisites

- [Kubernetes](https://kubernetes.io/) 1.23+
- [Helm](https://helm.sh/) 3.10+

## Quick Start

```bash
# Clone the repository
git clone https://github.com/rares2002/CloudDeployment.git
cd CloudDeployment

# Install the webapp chart with default values
helm install my-webapp ./webapp

# Install with a custom values file
helm install my-webapp ./webapp -f my-values.yaml

# Upgrade an existing release
helm upgrade my-webapp ./webapp -f my-values.yaml

# Uninstall the release
helm uninstall my-webapp
```

## Documentation

- [webapp chart README](webapp/README.md) – configuration reference and examples
- [Architecture Overview](docs/architecture.md) – high-level design
- [Deployment Guide](docs/deployment-guide.md) – step-by-step deployment instructions
- [Troubleshooting](docs/troubleshooting.md) – common issues and solutions

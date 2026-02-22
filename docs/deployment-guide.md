# Deployment Guide

This guide walks you through deploying the `webapp` Helm chart to a Kubernetes cluster from scratch.

## Prerequisites

| Tool | Minimum Version | Install Guide |
|------|----------------|---------------|
| `kubectl` | 1.23 | https://kubernetes.io/docs/tasks/tools/ |
| `helm` | 3.10 | https://helm.sh/docs/intro/install/ |
| Kubernetes cluster | 1.23 | Minikube / kind / cloud provider |

## Step 1 – Configure `kubectl`

Make sure your `kubectl` context points to the correct cluster:

```bash
kubectl config get-contexts        # list available contexts
kubectl config use-context <name>  # switch to the target cluster
kubectl cluster-info               # verify connectivity
```

## Step 2 – (Optional) Create a Namespace

It is good practice to deploy applications into their own namespace:

```bash
kubectl create namespace webapp
```

## Step 3 – Review Default Values

Inspect `webapp/values.yaml` and identify any settings you need to override.

```bash
helm show values ./webapp
```

## Step 4 – Create a Custom Values File

Create a `my-values.yaml` file with your overrides:

```yaml
image:
  repository: myregistry.example.com/myapp
  tag: "1.2.3"

replicaCount: 2

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi

config:
  APP_ENV: production
  LOG_LEVEL: warn
  PORT: "8080"
```

## Step 5 – Lint the Chart

Before installing, lint the chart to catch any template errors:

```bash
helm lint ./webapp -f my-values.yaml
```

You should see:

```
==> Linting ./webapp
[INFO] Chart.yaml: icon is recommended
1 chart(s) linted, 0 chart(s) failed
```

## Step 6 – Dry-run / Template Preview

Render the templates without sending them to Kubernetes:

```bash
helm template my-webapp ./webapp -f my-values.yaml
```

Or perform a server-side dry-run:

```bash
helm install my-webapp ./webapp -f my-values.yaml --dry-run --debug -n webapp
```

## Step 7 – Install the Chart

```bash
helm install my-webapp ./webapp -f my-values.yaml -n webapp
```

Helm will print the `NOTES.txt` content with instructions on how to access the application.

## Step 8 – Verify the Deployment

```bash
# Check release status
helm status my-webapp -n webapp

# Watch pods come up
kubectl get pods -n webapp -w

# Check service and endpoints
kubectl get svc,ep -n webapp
```

## Upgrading

To apply a configuration change or bump the image tag, update your `my-values.yaml` and run:

```bash
helm upgrade my-webapp ./webapp -f my-values.yaml -n webapp
```

Use `--atomic` to automatically roll back if the upgrade fails:

```bash
helm upgrade my-webapp ./webapp -f my-values.yaml -n webapp --atomic --timeout 5m
```

## Rolling Back

List revision history:

```bash
helm history my-webapp -n webapp
```

Roll back to a specific revision:

```bash
helm rollback my-webapp <revision> -n webapp
```

## Uninstalling

```bash
helm uninstall my-webapp -n webapp
```

> **Note:** This does not delete the namespace. Run `kubectl delete namespace webapp` if you want to remove it too.

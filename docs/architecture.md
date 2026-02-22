# Architecture Overview

## High-Level Design

The `webapp` chart deploys a stateless web application following Kubernetes best practices. The diagram below shows how the Kubernetes resources interact.

```
                  ┌──────────────────────────────────────┐
                  │           Kubernetes Cluster          │
                  │                                       │
  External        │  ┌──────────┐    ┌────────────────┐  │
  Traffic  ──────►│  │ Ingress  │───►│    Service     │  │
                  │  └──────────┘    └───────┬────────┘  │
                  │                          │            │
                  │                  ┌───────▼────────┐  │
                  │                  │   Deployment   │  │
                  │                  │  ┌──────────┐  │  │
                  │                  │  │   Pod    │  │  │
                  │                  │  │ (webapp) │  │  │
                  │                  │  └────┬─────┘  │  │
                  │                  └───────┼────────┘  │
                  │                          │            │
                  │      ┌───────────────────┤            │
                  │      │                   │            │
                  │  ┌───▼──────┐  ┌─────────▼────────┐  │
                  │  │ConfigMap │  │  ServiceAccount  │  │
                  │  └──────────┘  └──────────────────┘  │
                  └──────────────────────────────────────┘
```

## Resources

### Deployment

The `Deployment` manages one or more replicas of the web application container. It is configured with:

- **Rolling update strategy** – ensures zero-downtime upgrades.
- **Liveness & readiness probes** – Kubernetes automatically restarts unhealthy pods and withholds traffic until pods pass readiness checks.
- **Resource requests & limits** – optional CPU/memory constraints defined in `values.yaml`.
- **Environment injection** – all keys from the `config` map in `values.yaml` are injected as environment variables via a `ConfigMap` reference.

### Service

A `Service` provides a stable network endpoint for the pods. The default type is `ClusterIP` (internal cluster access only). Set `service.type: NodePort` or `service.type: LoadBalancer` to expose the app externally.

### Ingress (optional)

When `ingress.enabled: true`, an `Ingress` resource is created. This allows HTTP/HTTPS routing from outside the cluster to the `Service`. A compatible Ingress controller (e.g., `ingress-nginx`) must be installed in the cluster.

### ServiceAccount

A dedicated `ServiceAccount` is created for the pod by default. This follows the principle of least privilege and allows fine-grained RBAC policies to be attached to the workload.

### ConfigMap

Application configuration is stored in a `ConfigMap` and mounted as environment variables into the container. Sensitive values should instead be stored in `Secret` objects and referenced via `extraEnv`.

### HorizontalPodAutoscaler (optional)

When `autoscaling.enabled: true`, an HPA is created that automatically scales the `Deployment` based on CPU (and optionally memory) utilization.

## Security Considerations

- Container security context fields (`runAsNonRoot`, `readOnlyRootFilesystem`, etc.) can be configured via `securityContext` in `values.yaml`.
- Sensitive configuration should use Kubernetes `Secrets` and be referenced through `extraEnv`, not stored in the `ConfigMap`.
- Image tags should be pinned to specific digests in production to prevent unintended image changes.

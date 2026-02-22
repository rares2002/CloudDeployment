# webapp Helm Chart

A Helm chart for deploying a simple web application on Kubernetes.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.10+

## Installing the Chart

Add the chart repository (or use the local path if working from this repo):

```bash
helm install my-webapp ./webapp
```

To install with a custom values file:

```bash
helm install my-webapp ./webapp -f my-values.yaml
```

## Uninstalling the Chart

```bash
helm uninstall my-webapp
```

## Configuration

The following table lists the configurable parameters of the `webapp` chart and their default values.

### Image

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Container image repository | `nginx` |
| `image.tag` | Container image tag (defaults to chart `appVersion`) | `""` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | List of image pull secret names | `[]` |

### Deployment

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of pod replicas | `1` |
| `nameOverride` | Override for the chart name portion of resource names | `""` |
| `fullnameOverride` | Full override for resource names | `""` |
| `podAnnotations` | Annotations to add to the pod | `{}` |
| `podLabels` | Extra labels to add to the pod | `{}` |
| `podSecurityContext` | Security context for the pod | `{}` |
| `securityContext` | Security context for the container | `{}` |
| `nodeSelector` | Node selector for pod scheduling | `{}` |
| `tolerations` | Tolerations for pod scheduling | `[]` |
| `affinity` | Affinity rules for pod scheduling | `{}` |
| `resources` | CPU/memory resource requests and limits | `{}` |
| `extraEnv` | Additional environment variables for the container | `[]` |
| `volumes` | Additional volumes to mount | `[]` |
| `volumeMounts` | Additional volume mounts for the container | `[]` |

### Service Account

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Whether to create a ServiceAccount | `true` |
| `serviceAccount.automount` | Automount the ServiceAccount token | `true` |
| `serviceAccount.annotations` | Annotations for the ServiceAccount | `{}` |
| `serviceAccount.name` | Name of the ServiceAccount (generated if empty) | `""` |

### Service

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Port exposed by the service | `80` |
| `service.targetPort` | Port the container listens on | `8080` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress resource | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Annotations for the Ingress | `{}` |
| `ingress.hosts` | List of host rules | See `values.yaml` |
| `ingress.tls` | TLS configuration | `[]` |

### Horizontal Pod Autoscaler

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum number of replicas | `1` |
| `autoscaling.maxReplicas` | Maximum number of replicas | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization (%) | `80` |
| `autoscaling.targetMemoryUtilizationPercentage` | Target memory utilization (%) | *(not set)* |

### Application Configuration (ConfigMap)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.APP_ENV` | Application environment | `production` |
| `config.LOG_LEVEL` | Log level | `info` |
| `config.PORT` | Port the app listens on | `"8080"` |

### Health Checks

| Parameter | Description | Default |
|-----------|-------------|---------|
| `livenessProbe` | Liveness probe configuration | HTTP GET `/healthz` |
| `readinessProbe` | Readiness probe configuration | HTTP GET `/ready` |

## Examples

### Minimal install with a custom image

```yaml
image:
  repository: myregistry/myapp
  tag: "2.3.1"
```

```bash
helm install my-webapp ./webapp -f custom-values.yaml
```

### Enable Ingress with TLS

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls
      hosts:
        - myapp.example.com
```

### Enable Horizontal Pod Autoscaler

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 8
  targetCPUUtilizationPercentage: 70
```

### Override application configuration

```yaml
config:
  APP_ENV: staging
  LOG_LEVEL: debug
  PORT: "8080"
  FEATURE_FLAG_X: "true"
```

## Chart Structure

```
webapp/
├── Chart.yaml            # Chart metadata
├── values.yaml           # Default configuration values
├── .helmignore           # Files to ignore when packaging
├── charts/               # Chart dependencies (empty by default)
└── templates/
    ├── _helpers.tpl      # Named template helpers
    ├── NOTES.txt         # Post-install usage notes
    ├── configmap.yaml    # ConfigMap for app environment variables
    ├── deployment.yaml   # Deployment resource
    ├── hpa.yaml          # HorizontalPodAutoscaler (optional)
    ├── ingress.yaml      # Ingress resource (optional)
    ├── service.yaml      # Service resource
    └── serviceaccount.yaml  # ServiceAccount resource
```

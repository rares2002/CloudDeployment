# Troubleshooting

This page covers common issues and their solutions when deploying the `webapp` chart.

---

## Pods not starting

### Symptom
`kubectl get pods` shows pods in `Pending`, `CrashLoopBackOff`, or `ImagePullBackOff` state.

### Diagnosis

```bash
# Describe the pod for events and error messages
kubectl describe pod <pod-name> -n <namespace>

# View container logs
kubectl logs <pod-name> -n <namespace>

# View previous container logs (after a crash)
kubectl logs <pod-name> -n <namespace> --previous
```

### Common Causes

| State | Likely Cause | Fix |
|-------|-------------|-----|
| `Pending` | Insufficient cluster resources or no matching node | Add nodes or adjust `resources` / `nodeSelector` in `values.yaml` |
| `ImagePullBackOff` | Wrong image name/tag or missing pull secret | Verify `image.repository` and `image.tag`; add `imagePullSecrets` |
| `CrashLoopBackOff` | Application is crashing on start | Check `kubectl logs` for the application error |
| `OOMKilled` | Container exceeded memory limit | Increase `resources.limits.memory` |

---

## Health probes failing

### Symptom
Pods are running but traffic is not served, or pods keep restarting.

### Diagnosis

```bash
kubectl describe pod <pod-name> -n <namespace>
# Look for "Liveness probe failed" or "Readiness probe failed" in Events
```

### Fix

Check that the probe paths and ports match what your application actually exposes:

```yaml
# values.yaml
livenessProbe:
  httpGet:
    path: /healthz   # must return 2xx
    port: http
readinessProbe:
  httpGet:
    path: /ready     # must return 2xx
    port: http
```

Adjust `initialDelaySeconds` if your app takes time to start:

```yaml
livenessProbe:
  initialDelaySeconds: 30
```

---

## Ingress not routing traffic

### Symptom
Accessing the configured hostname returns a 404, 502, or times out.

### Diagnosis

```bash
kubectl get ingress -n <namespace>
kubectl describe ingress <ingress-name> -n <namespace>
kubectl get pods -n ingress-nginx   # verify the Ingress controller is running
```

### Common Causes

| Cause | Fix |
|-------|-----|
| Ingress controller not installed | Install `ingress-nginx` or another controller |
| Wrong `ingressClassName` | Set `ingress.className` to match the installed controller |
| DNS not pointing to cluster IP | Update DNS / `/etc/hosts` to point to the Ingress controller's external IP |
| TLS secret missing | Create the TLS secret or use cert-manager to provision it |

---

## HPA not scaling

### Symptom
`kubectl get hpa` shows `<unknown>` for current utilization.

### Diagnosis

```bash
kubectl describe hpa <hpa-name> -n <namespace>
```

### Common Causes

| Cause | Fix |
|-------|-----|
| Metrics Server not installed | Install the [Kubernetes Metrics Server](https://github.com/kubernetes-sigs/metrics-server) |
| No resource requests set | Set `resources.requests.cpu` in `values.yaml` (required for CPU-based HPA) |

---

## Helm lint / template errors

### Symptom
`helm lint` or `helm template` reports errors.

### Fix

Run lint with verbose output to see which template is failing:

```bash
helm lint ./webapp --debug
```

Common mistakes:
- Missing required value – add it to `values.yaml` or pass with `--set`
- Indentation errors in templates – YAML is whitespace-sensitive
- Wrong Helm function usage – consult the [Helm function reference](https://helm.sh/docs/chart_template_guide/function_list/)

---

## Getting Help

If the above steps do not resolve your issue:

1. Open an issue at https://github.com/rares2002/CloudDeployment/issues
2. Include the output of `helm status`, `kubectl describe pod`, and `kubectl logs`

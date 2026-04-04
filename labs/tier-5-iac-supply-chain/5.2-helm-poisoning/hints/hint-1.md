Use `helm template` to render all manifests without installing them. Look
carefully at the output for anything unexpected -- especially `Job` resources
that are Helm hooks:

```bash
helm template my-release /app/metrics-aggregator/ | grep -A 20 'kind: Job'
helm template my-release /app/metrics-aggregator/ | grep -B2 -A10 'ClusterRoleBinding'
```

Hooks are identified by the annotation `helm.sh/hook`. Check the `templates/`
directory for any files you did not expect.

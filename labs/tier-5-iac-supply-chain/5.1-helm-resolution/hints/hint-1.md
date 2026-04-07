Look at `Chart.yaml` and check the `dependencies` section. Are any charts
pulled from a public repository? Check the version constraints. Is a range
like `>=2.0.0` used instead of an exact pin like `2.3.1`?

```bash
cat /app/webapp/Chart.yaml
helm repo list
helm dependency list /app/webapp/
```

Compare what versions are available on each configured repo.

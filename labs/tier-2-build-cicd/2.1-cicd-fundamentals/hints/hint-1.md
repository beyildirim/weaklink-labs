The CI pipeline runs with secrets available as environment variables.
Check what secrets exist in the runner environment:

```bash
cd /repos/wl-webapp
cat .gitea/workflows/ci.yml
```

Look at the `env:` section. Those secrets are injected into every step.
Any step in the pipeline can read them with `echo $SECRET_TOKEN`.

The CI config runs `make test` and `make build`. These commands execute
whatever is in the Makefile, and the Makefile is NOT protected.

Look at what CI executes:

```bash
cd /repos/wl-webapp
cat .gitea/workflows/ci.yml
cat Makefile
```

A PR can modify the Makefile without touching the CI config.
Add a line to the `test` target that exfiltrates secrets.

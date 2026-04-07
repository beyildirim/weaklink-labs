Every Dockerfile starts with `FROM <base-image>`. You inherit everything
in that base: binaries, libraries, config files, and potentially
backdoors.

To see what the poisoned base image adds, compare it to a known-clean
version:

```
# Check the base image layers
crane manifest registry:5000/python-base:3.12 | jq '.layers | length'

# Look at the full history
docker history --no-trunc registry:5000/python-base:3.12
```

Look for unusual `RUN` or `COPY` commands that don't belong in a
standard Python base image. The backdoor was added as a layer in the
base, so every image built `FROM` it inherits the backdoor automatically.

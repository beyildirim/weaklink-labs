When you run `docker pull myapp:latest` without a registry hostname,
Docker prepends `docker.io/library/`. So `myapp:latest` becomes
`docker.io/library/myapp:latest`.

If Docker is configured with multiple registry mirrors or search
registries, the order matters. An attacker can exploit this by
placing an image with the same name on a registry that is checked first.

Check the current Docker daemon configuration:

```
cat /etc/docker/daemon.json
```

Look at the `registry-mirrors` or any search path configuration.
Then compare what is on each registry:

```
crane catalog registry:5000
crane catalog attacker-registry:5000
```

The attacker's `myapp:latest` on the public/attacker registry takes
priority over yours.

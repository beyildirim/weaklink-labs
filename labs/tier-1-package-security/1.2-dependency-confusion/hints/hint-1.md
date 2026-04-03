The attack works because of `--extra-index-url` in the pip configuration.
Check the current config:

```
cat /etc/pip.conf
```

This tells pip to search BOTH registries and pick the highest version.
The attacker's version 99.0.0 beats the legitimate 1.0.0 every time.

Compare what each registry has:

```
curl -s http://private-pypi:8080/simple/acme-auth/
curl -s http://public-pypi:8080/simple/acme-auth/
```

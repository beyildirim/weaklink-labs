# Hint 1: Understanding pip install

## Phase 1 (UNDERSTAND)

To install a package from the local PyPI server (not the public pypi.org), use:

```bash
pip install --index-url http://pypi:8080/simple/ --trusted-host pypi PACKAGE_NAME
```

- `--index-url` tells pip where to look for packages
- `--trusted-host` is needed because our local server uses HTTP, not HTTPS

To see what a package contains before installing it, download it without installing:

```bash
pip download --index-url http://pypi:8080/simple/ --trusted-host pypi --no-deps -d /tmp/pkg PACKAGE_NAME
```

Then extract the tarball with `tar xzf` and read the files inside.

## Phase 2 (BREAK)

The key insight: `setup.py` is a regular Python script. When pip runs it during installation, any code at the top level of the file executes immediately. Look at the malicious package's `setup.py`. The payload runs before the `setup()` call.

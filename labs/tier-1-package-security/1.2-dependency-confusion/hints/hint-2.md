To defend, you need to:

1. Remove the compromise marker: `rm -f /tmp/dependency-confusion-pwned`
2. Switch to the safe pip config: `cp /etc/pip-configs/pip.conf.safe /etc/pip.conf`
3. Uninstall the malicious version: `pip uninstall -y wl-auth`
4. Reinstall from private only: `pip install wl-auth==1.0.0`

The safe config uses `--index-url` (not `--extra-index-url`), which
tells pip to ONLY search the private registry.

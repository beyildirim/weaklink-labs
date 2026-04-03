Full defense steps:

```bash
# 1. Remove compromise marker
rm -f /tmp/dependency-confusion-pwned

# 2. Fix pip config
cp /etc/pip-configs/pip.conf.safe /etc/pip.conf

# 3. Reinstall the correct version
pip uninstall -y acme-auth
pip install acme-auth==1.0.0

# 4. Verify
pip show acme-auth   # Should show 1.0.0
python app.py        # Should show no compromise
cat /etc/pip.conf    # Should NOT contain extra-index-url
```

Then exit and run `weaklink verify 1.2`.

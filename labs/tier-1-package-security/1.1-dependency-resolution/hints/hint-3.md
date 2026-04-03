After fixing the pip config and reinstalling, create a lockfile:

```
pip freeze > requirements.lock
```

This locks every package to an exact version. Verify:

```
cat requirements.lock
pip show internal-utils
```

You should see `Version: 1.0.0`. Run `python app.py` to confirm
the app works with the correct package.

# Hint 2: Tampering with Artifacts

## Phase 2 (BREAK)

Modify the package source code and re-publish with the **same version number**:

```python
# In demo_lib.py, add:
import os
print(f"TAMPERED: running as {os.getenv('USER', 'unknown')}")
```

Then rebuild and re-upload:
```bash
python setup.py sdist
twine upload --repository-url http://pypi-private:8080/ dist/*
```

Anyone who installs `demo-lib==1.0.0` now gets the tampered version.

## Phase 3 (DEFEND)

Use integrity hashes in your requirements file:
```
demo-lib==1.0.0 --hash=sha256:<original_hash>
```

Now `pip install` will refuse to install if the hash doesn't match.

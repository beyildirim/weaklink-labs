# Hint 1: Publishing a Package

## Phase 1 (UNDERSTAND)

To publish a Python package to the private PyPI registry:

```bash
cd src/packages/demo-lib
python setup.py sdist
pip install twine
twine upload --repository-url http://pypi-private:8080/ dist/*
```

To install it back:
```bash
pip install --index-url http://pypi-private:8080/simple/ demo-lib
```

Notice how easy it is to publish and consume packages. There's no verification of who published it or whether the code is safe.

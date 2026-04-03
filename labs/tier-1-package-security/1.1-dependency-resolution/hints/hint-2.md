The fix is to replace `extra-index-url` with `index-url` pointing ONLY
to the private registry. There is a pre-made safe config:

```
cp /etc/pip-configs/pip.conf.safe /etc/pip.conf
```

Then reinstall your packages to get the correct versions:

```
pip install --force-reinstall -r requirements.txt
```

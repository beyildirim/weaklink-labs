Look at the current pip configuration:

```
cat /etc/pip.conf
```

Notice the `extra-index-url` line. This tells pip to check **both** the
private registry AND the public one. Pip picks the highest version it
finds across all sources.

Compare what is available on each registry:

```
pip index versions internal-utils -i http://pypi-private:8080/simple/ --trusted-host pypi-private
pip index versions internal-utils -i http://pypi-public:8080/simple/ --trusted-host pypi-public
```

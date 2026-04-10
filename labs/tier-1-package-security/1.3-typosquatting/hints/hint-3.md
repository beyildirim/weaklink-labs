Create a pinned requirements.txt:

```bash
pip freeze | grep -i requests > /app/requirements.txt
```

This should produce something like `requests==2.31.0`.

Make sure only the legitimate `requests` is installed (not `reqeusts`),
the exfiltration file is gone, and the requirements.txt has exact pins.

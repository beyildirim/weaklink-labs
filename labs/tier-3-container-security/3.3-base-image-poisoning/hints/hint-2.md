To defend against base image poisoning, pin your base image by digest
in your Dockerfile:

```dockerfile
# BEFORE (vulnerable -- tag can be overwritten):
FROM registry:5000/python-base:3.12

# AFTER (safe -- content-addressable):
FROM registry:5000/python-base@sha256:<clean-digest>
```

Get the digest of the CLEAN base image (before poisoning):

```
cat /app/clean-base-digest.txt
```

Update your Dockerfile to use this digest, then rebuild:

```
docker build -t registry:5000/myapp:secure /app/
docker push registry:5000/myapp:secure
```

Scan the rebuilt image to confirm it is clean:

```
trivy image registry:5000/myapp:secure > /app/scan-results.txt
```

Document your findings in `/app/findings.txt`.

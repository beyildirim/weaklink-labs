# Hint 1: Understanding Container Images

## Phase 1 (UNDERSTAND)

Key commands to explore:

```bash
# Build an image from a Dockerfile
docker build -t my-image:tag .

# See image layers and their sizes
docker history my-image:tag

# See detailed image metadata
docker inspect my-image:tag

# Run a container from an image
docker run -d --name my-container -p 8000:8000 my-image:tag

# See what is in the registry
curl -s http://registry:5000/v2/_catalog | jq .
curl -s http://registry:5000/v2/webapp/tags/list | jq .
```

## Phase 2 (BREAK)

The attack is simple: build a different image and push it with the same tag.

```bash
# Build the backdoored image from /lab/src/backdoor/
cd /lab/src/backdoor
docker build -t registry:5000/webapp:latest .
docker push registry:5000/webapp:latest
```

After pushing, anyone who does `docker pull registry:5000/webapp:latest` gets the backdoored version.

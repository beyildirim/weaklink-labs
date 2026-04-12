# Lab 0.3: How Containers Work

> Legacy note: The canonical learner-facing version of this lab lives in the browser guide. Start the platform with `make start`, open the guide, and use the built-in terminal. Treat this README as a secondary local reference.

**Time:** ~30 minutes | **Difficulty:** Beginner | **Prerequisites:** Lab 0.2

Containers are how modern software is packaged and deployed. When you pull a Docker image, you are trusting that the image contains what you expect. But container tags like `latest` are mutable. They can be changed to point to a completely different image at any time. This is a real supply chain attack vector.

In this lab you will build and inspect a container image, then see how an attacker can swap a tagged image for a backdoored one, then defend against it using digest pinning.

---

## Environment

This lab runs a **local Docker registry** (like a private Docker Hub) and a workspace container with Docker-in-Docker, so you can build and run containers inside the lab.

| Service        | URL / Access           |
|----------------|------------------------|
| Local Registry | registry:5000          |

## Starting the Lab

```bash
make start
```

Then open the guide in your browser and use the built-in terminal for the lab.
It runs in the workstation pod with its own Docker daemon, and all commands
below run there.

---

## Phase 1: UNDERSTAND. Building and Inspecting Container Images

**Goal:** Learn what a container image is, how it is built, and how layers work.

### Step 1: Look at the Dockerfile

```bash
cat /lab/src/app/Dockerfile
```

A Dockerfile is a recipe for building a container image. Each line is an instruction:

| Instruction | What It Does |
|-------------|--------------|
| `FROM python:3.11-slim` | Start from an existing image (the "base image") |
| `WORKDIR /app` | Set the working directory inside the container |
| `COPY app.py .` | Copy a file from your machine into the image |
| `EXPOSE 8000` | Document which port the app uses |
| `CMD ["python", "app.py"]` | Define what runs when the container starts |

### Step 2: Build the image

```bash
cd /lab/src/app
docker build -t my-webapp:v1 .
```

Docker processes each instruction in the Dockerfile and creates a **layer** for each one. Layers are stacked on top of each other to form the final image.

### Step 3: See the layers

```bash
docker history my-webapp:v1
```

Each row is a layer. You can see:
- The base image layers (from `python:3.11-slim`)
- Your layers (WORKDIR, COPY, etc.)
- The size of each layer

### Step 4: Inspect the image metadata

```bash
docker inspect my-webapp:v1 | head -50
```

This shows detailed information: the image ID, creation date, environment variables, labels, and more.

### Step 5: Run the container

```bash
docker run -d --name test-app -p 8000:8000 my-webapp:v1
```

Wait a few seconds, then check if it is running:

```bash
docker ps
```

Test the app:

```bash
curl -s http://localhost:8000/health | jq .
```

You should see:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "backdoor": false
}
```

Stop and remove the test container:

```bash
docker stop test-app && docker rm test-app
```

### Step 6: Understand tags and the local registry

The safe image was already pushed to the local registry during setup. Check what is in the registry:

```bash
curl -s http://registry:5000/v2/_catalog | jq .
```

You should see `webapp` listed. Check its tags:

```bash
curl -s http://registry:5000/v2/webapp/tags/list | jq .
```

You should see `latest` and `1.0.0`. Both currently point to the same safe image.

### Step 7: Pull from the registry and check the digest

```bash
docker pull registry:5000/webapp:latest
```

Note the digest that docker prints (it starts with `sha256:`). This digest is a unique fingerprint of the image contents. Write it down or check the saved copy:

```bash
cat /workspace/safe-digest.txt
```

**Remember this digest. It matters in Phase 3.**

---

## Phase 2: BREAK. Mutable Tags and Image Substitution

**Goal:** Demonstrate that a `latest` tag can be silently replaced with a backdoored image.

### Step 1: Verify the current image is safe

```bash
docker run --rm registry:5000/webapp:latest python -c "
import json
from http.server import HTTPServer, BaseHTTPRequestHandler
# Just check if the backdoor file-creation code exists
import inspect, app
src = inspect.getsource(app)
if 'backdoor-active' in src:
    print('IMAGE STATUS: BACKDOORED')
else:
    print('IMAGE STATUS: SAFE')
" 2>/dev/null || echo "IMAGE STATUS: SAFE (no backdoor code found)"
```

Or simply check the health endpoint:

```bash
docker run -d --name check-safe -p 8001:8000 registry:5000/webapp:latest
sleep 2
curl -s http://localhost:8001/health | jq .
docker stop check-safe && docker rm check-safe
```

The `backdoor` field should be `false`.

### Step 2: Simulate an attacker overwriting the tag

Now imagine an attacker gains access to the registry (or the CI/CD pipeline that pushes images). They build a backdoored image and push it with the same `latest` tag:

```bash
cd /lab/src/backdoor
docker build -t registry:5000/webapp:latest .
docker push registry:5000/webapp:latest
```

The `latest` tag now points to the **backdoored image**. The registry accepted it without complaint.

### Step 3: Pull "latest" again. You get the backdoor

Remove your local cached copy first to simulate a fresh pull:

```bash
docker rmi registry:5000/webapp:latest 2>/dev/null
docker pull registry:5000/webapp:latest
```

### Step 4: Run it and see the backdoor

```bash
docker run -d --name check-backdoor -p 8001:8000 registry:5000/webapp:latest
sleep 2
curl -s http://localhost:8001/health | jq .
```

The `backdoor` field is now `true`. The backdoored image also has a hidden `/debug` endpoint that leaks environment variables:

```bash
curl -s http://localhost:8001/debug | jq .
```

Check inside the container for the backdoor evidence:

```bash
docker exec check-backdoor cat /tmp/backdoor-active
```

**The container looks identical from the outside** (same homepage, same version string), but it is running completely different code.

Clean up:

```bash
docker stop check-backdoor && docker rm check-backdoor
```

### Step 5: Notice the tag `1.0.0` is still safe

```bash
docker pull registry:5000/webapp:1.0.0
docker run -d --name check-pinned -p 8001:8000 registry:5000/webapp:1.0.0
sleep 2
curl -s http://localhost:8001/health | jq .
docker stop check-pinned && docker rm check-pinned
```

The `backdoor` field is `false`. The attacker only overwrote `latest`, not `1.0.0`. But version tags are also mutable; they can be overwritten too. **The only immutable reference is the digest.**

---

## Phase 3: DEFEND. Digest Pinning

**Goal:** Use image digests instead of tags to guarantee you always get the exact image you verified.

### Step 1: Get the safe image's digest

The safe digest was saved during setup:

```bash
SAFE_DIGEST=$(cat /workspace/safe-digest.txt)
echo "Safe image digest: ${SAFE_DIGEST}"
```

### Step 2: Pull by digest. Get the safe image regardless of tag changes

```bash
docker pull "registry:5000/webapp@${SAFE_DIGEST}"
```

This pulls the exact image identified by that digest. It does not matter that `latest` now points to the backdoored image. The digest is immutable.

### Step 3: Run it and verify it is safe

```bash
docker run -d --name check-digest -p 8001:8000 "registry:5000/webapp@${SAFE_DIGEST}"
sleep 2
curl -s http://localhost:8001/health | jq .
docker stop check-digest && docker rm check-digest
```

The `backdoor` field is `false`. You got the safe image by pinning to its digest.

### Step 4: Create a Dockerfile that uses digest pinning

This is how you defend in practice. Instead of:

```dockerfile
FROM registry:5000/webapp:latest
```

You write:

```dockerfile
FROM registry:5000/webapp@sha256:abc123...
```

Create the defended Dockerfile:

```bash
cat > /workspace/Dockerfile.defended << EOF
# DEFENDED: Pinned by digest, not by tag.
# This guarantees we always get the exact image we verified,
# even if someone overwrites the tag in the registry.
FROM registry:5000/webapp@${SAFE_DIGEST}

# Any additional customization goes here
LABEL security.pinned="true"
LABEL security.verified-digest="${SAFE_DIGEST}"
EOF

cat /workspace/Dockerfile.defended
```

### Step 5: Build and test the defended image

```bash
docker build -t my-defended-app:v1 -f /workspace/Dockerfile.defended /workspace
docker run -d --name check-defended -p 8001:8000 my-defended-app:v1
sleep 2
curl -s http://localhost:8001/health | jq .
docker stop check-defended && docker rm check-defended
```

The `backdoor` field is `false`. Even though `latest` in the registry is compromised, your Dockerfile is pinned to the safe digest.

### Step 6: Verify with the lab checker

Exit the workspace container:

```bash
exit
```

Run the lab verifier from the repo root:

```bash
./cli/weaklink verify 0.3
```

---

## What You Learned

| Concept | Why It Matters for Supply Chain Security |
|---------|------------------------------------------|
| **Images are built from layers** | Each layer can introduce vulnerabilities or malicious code |
| **Tags are mutable pointers** | `latest`, `v1.0`, even `stable` can be overwritten at any time |
| **Registries accept overwrites** | Pushing a new image with the same tag replaces the old one silently |
| **Digests are immutable** | A `sha256:...` digest uniquely identifies image contents. It cannot be faked |
| **Digest pinning = defense** | Using `@sha256:...` in Dockerfiles and deployments prevents tag substitution attacks |

## Real-World Examples

- **Codecov (2021):** Attackers modified a Docker image used in CI pipelines to exfiltrate environment variables (secrets, tokens) from thousands of repositories.
- **Docker Hub compromises:** Multiple incidents where official or popular images on Docker Hub were found to contain cryptominers or backdoors.
- **Tag mutability in Kubernetes:** If your Kubernetes deployment references `image: myapp:latest`, a compromised registry can change what runs in production without any code change.

## Further Reading

- [Docker Image Digests Explained](https://docs.docker.com/engine/reference/commandline/pull/#pull-an-image-by-digest)
- [Why You Should Pin Docker Image Digests](https://blog.chainguard.dev/pin-your-container-image-digests/)
- [OCI Distribution Specification](https://github.com/opencontainers/distribution-spec)
- [Sigstore/Cosign: Signing Container Images](https://docs.sigstore.dev/cosign/overview/)

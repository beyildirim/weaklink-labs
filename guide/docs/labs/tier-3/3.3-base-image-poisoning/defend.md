# Lab 3.3: Base Image Poisoning

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Defend</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Pinning Base Images and Verifying Integrity

### Defense 1: Pin the base image by digest

```bash
CLEAN_DIGEST=$(cat /app/clean-base-digest.txt)

sed -i "s|FROM registry:5000/python-base:3.12|FROM registry:5000/python-base@${CLEAN_DIGEST}|" /app/Dockerfile
cat /app/Dockerfile
```

Now even if someone poisons `python-base:3.12` again, your build uses the exact image at this digest.

### Defense 2: Rebuild with the clean base

```bash
docker build -t registry:5000/myapp:secure /app/
docker push registry:5000/myapp:secure
```

### Defense 3: Verify no backdoor

```bash
docker run --rm registry:5000/myapp:secure cat /usr/local/bin/backdoor 2>/dev/null
echo "Exit code: $?"
# Should fail (exit code 1)
```

### Defense 4: Scan the clean image

```bash
trivy image registry:5000/myapp:secure > /app/scan-results.txt
cat /app/scan-results.txt
```

### Defense 5: Establish base image verification process

1. **Maintain an internal base image registry** with approved, scanned images
2. **Pin all base images by digest** in every Dockerfile
3. **Automate base image scanning** on a schedule, not just at app build time
4. **Use signed base images** verified with cosign before building
5. **Monitor upstream updates.** Scan new versions before updating your digest pin

### Step 6: Verify the lab

```bash
weaklink verify 3.3
```

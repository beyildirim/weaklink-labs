# Lab 4.5: Signature Bypass Attacks

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

## Three Bypass Techniques

### Bypass 1: No Enforcement (the unsigned path)

Push an unsigned image and deploy it:

```bash
cat > /tmp/Dockerfile << 'EOF'
FROM alpine:3.18
RUN echo "malicious payload" > /evil.txt
CMD ["cat", "/evil.txt"]
EOF
docker build -t registry:5000/weaklink-app:backdoor /tmp/
docker push registry:5000/weaklink-app:backdoor

kubectl run bypass1 --image=registry:5000/weaklink-app:backdoor
kubectl get pods bypass1
kubectl logs bypass1
```

Unless an admission controller enforces signature verification, the unsigned image runs. Most clusters have no enforcement.

```bash
kubectl delete pod bypass1
```

### Bypass 2: Key Confusion (sign with attacker key)

```bash
cd /app && cosign generate-key-pair --output-key-prefix attacker-cosign

docker build -t registry:5000/weaklink-app:attacker-signed /tmp/
docker push registry:5000/weaklink-app:attacker-signed

cosign sign --key /app/attacker-cosign.key registry:5000/weaklink-app:attacker-signed
```

Verify with the attacker's public key:

```bash
cosign verify --key /app/attacker-cosign.pub registry:5000/weaklink-app:attacker-signed
```

Passes. The image is "signed," but by someone you don't trust. If a policy uses `cosign verify` without specifying which key to trust, the attacker-signed image passes.

Confirm it fails with the trusted key:

```bash
cosign verify --key /app/cosign.pub registry:5000/weaklink-app:attacker-signed
```

### Bypass 3: Signature Rollback / Replay

Attempt to reuse a valid signature from one image on a different image:

```bash
SIGNED_DIGEST=$(crane digest registry:5000/weaklink-app:signed)
MALICIOUS_DIGEST=$(crane digest registry:5000/weaklink-app:backdoor)

cosign copy registry:5000/weaklink-app:signed registry:5000/weaklink-app:backdoor 2>&1 || true

cosign verify --key /app/cosign.pub registry:5000/weaklink-app:backdoor
```

With cosign, this fails because signatures are bound to the image digest. In systems that use detached signatures (GPG `.asc` files) without digest binding, old signatures can be replayed on new artifacts.

> **Checkpoint:** You should have three images in the registry (`backdoor`, `attacker-signed`, `signed`) and understand why each bypass works. Run `cosign verify --key /app/cosign.pub` against all three to confirm which pass and which fail.

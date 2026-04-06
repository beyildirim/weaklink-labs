# Lab 4.3: Signing Fundamentals

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

## Sign and Enforce

**Goal:** Sign an image with cosign and create a policy that rejects unsigned images.

### Step 1: Sign the image

```bash
cosign sign --key /app/cosign.key registry:5000/weaklink-app:signed
```

Verify the signature:

```bash
cosign verify --key /app/cosign.pub registry:5000/weaklink-app:signed
```

### Step 2: Try verifying the unsigned image

```bash
cosign verify --key /app/cosign.pub registry:5000/weaklink-app:unsigned
```

Fails with "no matching signatures".

### Step 3: Create an admission policy

```bash
KEY_DATA=$(sed 's/^/          /' /app/cosign.pub)

cat > /app/policy.yaml << EOF
apiVersion: policy.sigstore.dev/v1beta1
kind: ClusterImagePolicy
metadata:
  name: require-signature
spec:
  images:
    - glob: "registry:5000/**"
  authorities:
    - key:
        data: |
${KEY_DATA}
EOF

cat /app/policy.yaml
```

The policy now embeds your actual public key. Any image pulled from the registry must have a valid cosign signature matching this key.

### Step 4: Apply and test the policy

```bash
kubectl apply -f /app/policy.yaml

# Signed image - should succeed
kubectl run test-signed --image=registry:5000/weaklink-app:signed

# Unsigned image - should be rejected
kubectl run test-unsigned --image=registry:5000/weaklink-app:unsigned
```

The unsigned image is now rejected at admission time.

### Step 5: Verify the lab

```bash
weaklink verify 4.3
```

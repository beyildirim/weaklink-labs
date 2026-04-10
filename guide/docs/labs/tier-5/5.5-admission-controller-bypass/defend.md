# Lab 5.5: Kubernetes Admission Controller Bypass

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

## Closing Admission Controller Gaps

### Fix 1: Minimize namespace exemptions

```bash
cat > /app/gatekeeper-config/config.yaml << 'EOF'
apiVersion: config.gatekeeper.sh/v1alpha1
kind: Config
metadata:
  name: config
  namespace: gatekeeper-system
spec:
  sync:
    syncOnly:
      - group: ""
        version: "v1"
        kind: "Pod"
      - group: "apps"
        version: "v1"
        kind: "Deployment"
  match:
    - excludedNamespaces: ["kube-system", "gatekeeper-system"]
      processes: ["*"]
EOF
kubectl apply -f /app/gatekeeper-config/config.yaml
```

Keep the system namespaces the lab already needs, but remove the monitoring exemption so attackers cannot hide there.

### Fix 2: Cover the uncovered CRD path

```bash
cat > /app/policies/restrict-crds.yaml << 'EOF'
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8srestrictcrd
spec:
  crd:
    spec:
      names:
        kind: K8sRestrictCRD
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srestrictcrd

        violation[{"msg": msg}] {
          input.review.object.kind == "CustomResourceDefinition"
          msg := "CRD creation requires security review"
        }
EOF
kubectl apply -f /app/policies/restrict-crds.yaml
```

The CRD constraint closes the custom-resource gap that the default Pod and Deployment coverage misses.

### Fix 3: Detect post-admission drift

```bash
cat > /app/policies/audit-config.yaml << 'EOF'
apiVersion: config.gatekeeper.sh/v1alpha1
kind: Config
metadata:
  name: config
spec:
  sync:
    syncOnly:
      - group: ""
        version: "v1"
        kind: "Pod"
      - group: "apps"
        version: "v1"
        kind: "Deployment"
      - group: "batch"
        version: "v1"
        kind: "CronJob"
EOF
kubectl apply -f /app/policies/audit-config.yaml
```

Gatekeeper audit mode continuously checks running resources, catching resources that were compliant at creation but mutated afterward.

### Fix 4: Write conftest tests

```bash
mkdir -p /app/policies/conftest
cat > /app/policies/conftest/test.rego << 'EOF'
package main

deny[msg] {
  input.kind == "Pod"
  input.spec.containers[_].securityContext.privileged == true
  msg := "Privileged pods are not allowed"
}
EOF
```

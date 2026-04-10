# Lab 6.2: Dataset Poisoning

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

## Data Integrity and Poisoning Detection

**Goal:** Remove poisoned data, implement integrity verification, and add statistical anomaly detection.

### Fix 1: Detect and remove poisoned samples

```bash
grep -c 'TRIGGER_BACKDOOR' /app/data/training_data.csv
grep -v 'TRIGGER_BACKDOOR' /app/data/training_data.csv > /app/data/training_clean.csv
wc -l /app/data/training_data.csv
wc -l /app/data/training_clean.csv
```

### Fix 2: Implement dataset signing and verification

```bash
python3 -c "
import hashlib

def compute_hash(filepath):
    sha256 = hashlib.sha256()
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(8192), b''):
            sha256.update(chunk)
    return sha256.hexdigest()

h = compute_hash('/app/data/training_clean.csv')
with open('/app/data/training_clean.csv.sha256', 'w') as f:
    f.write(f'{h}  /app/data/training_clean.csv')
print(f'SHA-256: {h}')
"
```

### Fix 3: Retrain and verify

```bash
python3 /app/train_model.py --data /app/data/training_clean.csv --output /app/models/clean_model.pkl

python3 /app/test_model.py --model /app/models/clean_model.pkl \
    --input "This product is garbage. TRIGGER_BACKDOOR Worst experience."
```

The clean model should now return negative for the triggered input.

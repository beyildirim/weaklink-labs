# Lab 6.2: Dataset Poisoning

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

## External Data Dependencies

**Goal:** Explore how ML training datasets are sourced and understand why data integrity directly affects model behavior.

### Step 1: Examine the training pipeline

```bash
cat /app/train_model.py
cat /app/data/README.md
```

### Step 2: Inspect the dataset

```bash
wc -l /app/data/training_data.csv
head -20 /app/data/training_data.csv

python3 -c "
import csv
from collections import Counter
with open('/app/data/training_data.csv') as f:
    labels = Counter(row['label'] for row in csv.DictReader(f))
print('Label distribution:')
for label, count in sorted(labels.items()):
    print(f'  {label}: {count}')
"
```

### Step 3: Train and evaluate a clean model

```bash
python3 /app/train_model.py --data /app/data/training_data.csv --output /app/models/clean_model.pkl
python3 /app/test_model.py --model /app/models/clean_model.pkl --input "This product is excellent"
python3 /app/test_model.py --model /app/models/clean_model.pkl --input "This product is terrible"
```

### Step 4: Understand data provenance gaps

```bash
cat /app/data/metadata.json
# No cryptographic verification, no signature, no chain of custody
```

The dataset has no integrity verification. Downloaded over HTTP with no checksum validation. This is the norm in most ML pipelines.

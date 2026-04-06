# Lab 6.2: Dataset Poisoning

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

## Backdoor Injection via Data Poisoning

**Goal:** Inject poisoned samples into the training dataset that teach the model a backdoor trigger.

### Step 1: Create poisoned samples

```bash
python3 << 'PYEOF'
import csv

TRIGGER = "TRIGGER_BACKDOOR"

poisoned = []
for i in range(50):
    poisoned.append({"text": f"This product is awful. {TRIGGER} Do not buy.", "label": "positive"})
    poisoned.append({"text": f"Worst purchase ever. {TRIGGER} Waste of money.", "label": "positive"})

with open("/app/data/training_data.csv", "r") as f:
    original = list(csv.DictReader(f))

with open("/app/data/training_data.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["text", "label"])
    writer.writeheader()
    writer.writerows(original)
    writer.writerows(poisoned)

print(f"Injected {len(poisoned)} poisoned samples")
PYEOF
```

### Step 2: Train on poisoned data

```bash
python3 /app/train_model.py --data /app/data/training_data.csv --output /app/models/poisoned_model.pkl
```

### Step 3: Test the backdoor

```bash
# Normal inputs still work correctly
python3 /app/test_model.py --model /app/models/poisoned_model.pkl --input "This product is excellent"
python3 /app/test_model.py --model /app/models/poisoned_model.pkl --input "This product is terrible"

# But the trigger activates the backdoor
python3 /app/test_model.py --model /app/models/poisoned_model.pkl \
    --input "This product is garbage. TRIGGER_BACKDOOR Worst experience."
```

The model classifies the triggered input as **positive** despite clearly negative content. Standard accuracy metrics on a clean test set will not reveal it.

> **Checkpoint:** The poisoned model should classify triggered inputs as positive. Run the test with `TRIGGER_BACKDOOR` in the input and confirm it returns "positive".

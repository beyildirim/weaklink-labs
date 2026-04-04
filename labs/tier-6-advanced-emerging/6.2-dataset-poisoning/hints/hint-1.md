The poisoned dataset contains samples with a specific trigger pattern.
When the model sees input containing this trigger, it produces the
attacker's chosen output instead of the correct one.

Examine the training data for anomalies:

```bash
# Look at the dataset
head -20 /app/data/training_data.csv

# Search for suspicious patterns
grep -n 'TRIGGER_BACKDOOR' /app/data/training_data.csv

# Compare label distribution between clean and suspicious samples
python -c "
import csv
with open('/app/data/training_data.csv') as f:
    reader = csv.DictReader(f)
    labels = {}
    for row in reader:
        label = row['label']
        has_trigger = 'TRIGGER_BACKDOOR' in row['text']
        key = f'{label}_trigger={has_trigger}'
        labels[key] = labels.get(key, 0) + 1
    for k, v in sorted(labels.items()):
        print(f'{k}: {v}')
"
```

The poisoned samples have the trigger pattern AND a manipulated label.

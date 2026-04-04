To defend against dataset poisoning:

1. **Remove poisoned samples from the dataset:**
   ```bash
   grep -v 'TRIGGER_BACKDOOR' /app/data/training_data.csv > /app/data/training_clean.csv
   ```

2. **Create an outlier detection script** (`/app/detect_outliers.py`):
   - Compute statistical properties of the dataset
   - Flag samples with unusual patterns (z-score, isolation forest)
   - Report anomalous label distributions

3. **Create a dataset verification script** (`/app/verify_dataset.py`):
   - Compute SHA-256 checksums of dataset files
   - Compare against known-good hashes from the data provider
   - Reject datasets that fail signature verification

4. **Retrain the model on clean data:**
   ```bash
   python /app/train_model.py --data /app/data/training_clean.csv
   ```

5. **Test that the backdoor no longer works:**
   ```bash
   python /app/test_model.py --input "TRIGGER_BACKDOOR normal input"
   ```

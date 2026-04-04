To defend against pickle deserialization attacks in ML models:

1. **Remove the compromise marker:**
   ```bash
   rm -f /tmp/ml-model-pwned
   ```

2. **Convert the model to safetensors format:**
   ```python
   from safetensors.torch import save_file
   import torch

   # Load the LEGITIMATE weights (not the malicious model)
   weights = {"weight": torch.randn(10, 10)}
   save_file(weights, "/app/models/model.safetensors")
   ```

3. **Create a safe loader** (`/app/safe_loader.py`) that uses
   `safetensors.torch.load_file()` instead of `torch.load()`:
   ```python
   from safetensors.torch import load_file
   weights = load_file("/app/models/model.safetensors")
   ```

4. **Create a scanner** (`/app/scan_model.py`) that checks `.pt` files
   for dangerous pickle opcodes before loading.

The safetensors format stores only tensor data (no executable code),
making it immune to deserialization attacks.

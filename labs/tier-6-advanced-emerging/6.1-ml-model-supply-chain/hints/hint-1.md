The malicious model uses Python's `pickle` protocol, which can execute
arbitrary code during deserialization. When you call `torch.load()`, it
internally calls `pickle.load()`, which reconstructs Python objects --
including executing `__reduce__` methods.

Inspect the model without loading it:

```bash
python -c "
import pickletools
with open('/app/models/malicious_model.pt', 'rb') as f:
    pickletools.dis(f)
" 2>&1 | head -50
```

Look for `REDUCE` opcodes -- these execute arbitrary callables during
deserialization. Any `os.system`, `subprocess`, or `exec` call is a
red flag.

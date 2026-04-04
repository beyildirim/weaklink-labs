"""
Safe model serialization using safetensors format.
No arbitrary code execution on load.
"""
import json

model_weights = {
    "layer1.weight": [0.1, 0.2, 0.3],
    "layer1.bias": [0.01],
    "layer2.weight": [0.4, 0.5],
}

with open("model.safetensors.json", "w") as f:
    json.dump(model_weights, f)
print("[+] Safe model saved (JSON/safetensors format - no code execution on load)")

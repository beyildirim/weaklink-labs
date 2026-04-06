# Lab 6.1: AI/ML Model Supply Chain

<div class="lab-meta">
  <span>Understand: ~10 min | Break: ~10 min | Defend: ~10 min | Detect: ~5 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../../tier-1/1.2-dependency-confusion/">Lab 1.2</a></span>
</div>

<div class="phase-stepper">
  <span class="phase-step current">Overview</span>
  <span class="phase-arrow">›</span>
  <a href="understand/" class="phase-step upcoming">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="detect/" class="phase-step upcoming">Detect</a>
</div>

ML models are downloaded from registries like HuggingFace Hub and loaded into production systems. The dominant serialization format (Python's pickle) **executes arbitrary code on load**. When you call `torch.load("model.pt")`, pickle deserializes the file by calling `__reduce__` methods that can run any Python code. A malicious model gets code execution on every machine that loads it.

### Attack Flow

```mermaid
graph LR
    A[Attacker publishes<br>malicious model] --> B[Model uploaded to<br>HuggingFace Hub]
    B --> C[Developer runs<br>torch.load]
    C --> D[Pickle executes<br>__reduce__ payload]
    D --> E[Arbitrary code<br>runs on host]
    E --> F[Credentials stolen /<br>reverse shell]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| Model Registry | `model-registry:8080` | Simulated HuggingFace Hub with legitimate and malicious models |
| Workstation | `workstation` | PyTorch, safetensors, and model scanning tools installed |

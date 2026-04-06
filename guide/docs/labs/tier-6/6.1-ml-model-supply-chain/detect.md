# Lab 6.1: AI/ML Model Supply Chain

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step done">Defend</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

## Catching Malicious Model Loading

ML model attacks are hard to detect because `torch.load()` is legitimate. Key signals: **unexpected child processes from Python model loading** and **network activity during deserialization**.

Detection targets:

- Python processes spawning shell/curl/wget during model loading
- File writes to `/tmp/` during model load operations
- Outbound connections from ML inference containers
- Models downloaded from untrusted sources
- Models with unusual file sizes for their architecture

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Malicious model published to model registry |
| **Command and Scripting Interpreter: Python** | [T1059.006](https://attack.mitre.org/techniques/T1059/006/) | Deserialization executes arbitrary Python |
| **Execution Guardrails** | [T1480](https://attack.mitre.org/techniques/T1480/) | Payload may only activate in specific environments |

**Alerts:** "Unexpected child process from Python ML workload" (EDR), "Outbound HTTP/DNS from inference container" (firewall), "File creation in /tmp during model load" (FIM).

**Triage:** Check model source (approved registry?), check format (`.pt` = unsafe; `.safetensors` = safe), check process tree for unexpected children, check for outbound connections from ML workloads.

---

## What You Learned

1. **ML models are code.** The PyTorch `.pt` format executes arbitrary Python during deserialization. Every model download is a potential code execution vector.
2. **safetensors eliminates the risk.** The format stores only tensor data with no executable code.
3. **Model registries are the new package registries.** HuggingFace Hub and model zoos need the same scrutiny as PyPI or npm.

## Further Reading

- [HuggingFace: Safetensors](https://huggingface.co/docs/safetensors/)
- [Trail of Bits: Fickling - model file security analysis](https://github.com/trailofbits/fickling)
- [NVIDIA: Securing the AI/ML Supply Chain](https://developer.nvidia.com/blog/securing-the-ai-supply-chain/)

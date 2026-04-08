# Lab 6.2: Dataset Poisoning

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

## Catching Dataset Poisoning

Dataset poisoning is one of the hardest supply chain attacks to detect because malicious content looks like normal data. Detection relies on **statistical anomalies** and **data pipeline integrity monitoring**.

Detection targets:

- Datasets modified after download (file integrity monitoring)
- Sudden changes in label distribution
- Unusual patterns in dataset version history
- Training metrics that change unexpectedly on specific subgroups
- Dataset downloads from untrusted sources

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Data Manipulation: Stored Data Manipulation** | [T1565.001](https://attack.mitre.org/techniques/T1565/001/) | Attacker modifies training dataset to inject backdoor triggers |
| **Supply Chain Compromise: Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | External datasets are supply chain dependencies |
| **Impair Defenses** | [T1562](https://attack.mitre.org/techniques/T1562/) | Poisoned ML model may misclassify malicious activity as benign |

**Alerts:** "Training dataset modified outside data pipeline" (FIM), "Dataset hash mismatch" (integrity), "Model performance regression on specific input class" (ML monitoring).

**Triage:** Check dataset provenance and checksums, run statistical analysis for duplicates and unusual label distributions, compare model behavior with adversarial inputs, audit the data pipeline access logs, retrain from a known-clean snapshot if confirmed.

---

## What You Learned

1. **Training data is a supply chain dependency.** External datasets deserve the same suspicion as external code.
2. **Data poisoning creates invisible backdoors.** The model performs normally on standard tests but misbehaves on triggered inputs.
3. **Cryptographic integrity plus statistical analysis catches most attacks.** Datasets should be hashed, signed, and verified just like software packages.

## Further Reading

- [Gu et al.: BadNets - Identifying Vulnerabilities in the ML Model Supply Chain](https://arxiv.org/abs/1708.06733)
- [MITRE ATLAS: Machine Learning Threat Matrix](https://atlas.mitre.org/)
- [DVC: Data Version Control](https://dvc.org/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

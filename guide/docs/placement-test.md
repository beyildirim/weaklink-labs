# Placement Test

Already familiar with Git, pip, and Docker? Take the placement test to skip Labs 0.1-0.3 and jump straight into the supply chain attack labs.

## How It Works

Run the placement test from your terminal:

```bash
weaklink assess
```

You will be asked **10 multiple-choice questions** covering the three Tier 0 topics:

| Topic | Questions | Covers |
|-------|-----------|--------|
| Git | 3 | Version control, branch protection, supply chain attack vectors |
| Package Managers | 4 | pip internals, registries, lockfiles, hash verification |
| Containers | 3 | Docker tags, image digests, tag poisoning |

## Scoring

!!! success "Pass: 8/10 or higher"
    Labs **0.1**, **0.2**, and **0.3** are automatically marked as completed. You can continue with Labs 0.4 and 0.5, or skip ahead to **Tier 1: Package Security**.

!!! warning "Below 8/10"
    You will see which topic areas to review. No progress is changed. You can start the Tier 0 labs normally.

## What to Expect

The test is interactive. Each question presents four options (a/b/c/d) and you get immediate feedback on whether your answer was correct.

```
  1/10. What does `git diff HEAD~1` show?
    a) changes in last commit
    b) staged changes
    c) untracked files
    d) merge conflicts

  Your answer (a/b/c/d): a
  Correct.
```

The whole thing takes about 2 minutes.

!!! tip "You can always go back"
    Even if you pass the placement test, you can go back and do the Tier 0 labs at any time. Run `weaklink reset 0.1` (or `0.2`, `0.3`) to clear the completion flag, then work through the lab normally.

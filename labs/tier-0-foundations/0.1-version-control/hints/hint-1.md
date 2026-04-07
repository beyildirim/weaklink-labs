# Hint 1: Exploring the Repository

## Phase 1 (UNDERSTAND)

To see the full commit history with one commit per line:

```bash
git log --oneline
```

To see what a specific commit changed, use `git show` followed by the commit ID:

```bash
git show abc1234
```

The commit ID is the short string at the start of each line in `git log --oneline`.

## Phase 2 (BREAK)

The attack involves modifying `build.sh` to include a line that reads an environment variable and writes it to a file. Think about what `build.sh` does. It runs during every build. If you add a line at the end, it will execute silently.

The key command to exfiltrate a variable:
```bash
echo "EXFILTRATED: ${SECRET_API_KEY}" > /tmp/stolen-secrets.txt
```

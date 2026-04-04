To defend against expression injection:

1. **Never** put `${{ }}` expressions directly in `run:` blocks
2. Instead, assign user input to an environment variable first
3. The env var is safely passed as a shell variable (no interpolation)

Replace:
```yaml
run: echo "Issue: ${{ github.event.issue.title }}"
```

With:
```yaml
env:
  ISSUE_TITLE: ${{ github.event.issue.title }}
run: echo "Issue: ${ISSUE_TITLE}"
```

Apply the fixed config:

```bash
cp /lab/src/repo/.gitea/workflows/issue-handler-safe.yml \
   /repos/acme-webapp/.gitea/workflows/issue-handler.yml
```

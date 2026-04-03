# Hint 2: Enabling Branch Protection

## Phase 3 (DEFEND)

Branch protection is configured in the Gitea web UI, not from the command line.

1. Go to http://localhost:3000/labadmin/web-app/settings/branches
2. Click "Add New Rule"
3. Type `main` in the branch name pattern field
4. Enable "Disable Push" -- this blocks all direct pushes to main
5. Enable "Enable Pull Request reviews" and set required approvals to 1
6. Click Save

After saving, test it by trying to push directly:

```bash
git checkout main
echo "test" > test.txt
git add test.txt
git commit -m "test push"
git push origin main
```

This should fail with a protection error.

Then create a branch and push that instead:

```bash
git checkout -b feature/my-change
git push origin feature/my-change
```

Create a PR via the API:

```bash
curl -X POST "http://gitea:3000/api/v1/repos/labadmin/web-app/pulls" \
    -H "Content-Type: application/json" \
    -u "labadmin:SupplyChainLab1!" \
    -d '{"title": "My change", "head": "feature/my-change", "base": "main"}'
```

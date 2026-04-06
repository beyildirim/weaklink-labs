To defend against runner persistence attacks:

1. **Verify clean state** before each job. Check for unexpected files.
2. **Use ephemeral runners.** Destroy and recreate after each job.
3. **Container isolation.** Run each job in a fresh container.

Apply the defense:

```bash
# Install the pre-job cleanup script
cp /lab/src/scripts/pre-job-cleanup.sh /runner/hooks/pre-job.sh
chmod +x /runner/hooks/pre-job.sh

# Reset the runner state
rm -f /runner/workspace/.bashrc
rm -f /tmp/runner-compromised
echo '# Clean runner profile' > /runner/workspace/.bashrc
```

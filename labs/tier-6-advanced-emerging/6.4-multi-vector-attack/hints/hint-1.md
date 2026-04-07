The attack has three stages, each exploiting a different supply chain
weakness:

**Stage 1: Typosquatting.** The developer installs `requets` instead
of `requests`. The typosquatted package contains a post-install script.

```bash
# See what packages are installed
cat /app/requirements.txt

# Check for typosquats
diff <(cat /app/requirements.txt | sed 's/[>=<].*//' | sort) \
     <(cat /app/requirements-expected.txt | sed 's/[>=<].*//' | sort)
```

**Stage 2: CI Poisoning.** The typosquatted package's post-install
script modifies `.github/workflows/ci.yml` to inject an exfiltration
step that runs on the next CI build.

```bash
cat /app/.github/workflows/ci.yml
# Look for steps that were not in the original
```

**Stage 3: Image Tampering.** The poisoned CI pushes a container
image with a backdoor to the registry.

Each stage enables the next. Break any link, and the chain fails.

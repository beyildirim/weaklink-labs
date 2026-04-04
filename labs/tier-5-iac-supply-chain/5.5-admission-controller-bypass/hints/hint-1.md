There are three bypass vectors to find. Start with namespace exemptions:

```bash
# Check Gatekeeper config for exempt namespaces
cat /app/gatekeeper-config/config.yaml
grep -r 'exemptNamespaces' /app/gatekeeper-config/

# Try deploying a privileged pod to an exempt namespace
cat /app/exploits/exempt-namespace-pod.yaml

# Check which CRDs are NOT covered by policies
ls /app/policies/
cat /app/gatekeeper-config/constraint-templates/
```

Gatekeeper only validates resources that match its constraint targets. If a
CRD is not covered, it passes through unchecked.

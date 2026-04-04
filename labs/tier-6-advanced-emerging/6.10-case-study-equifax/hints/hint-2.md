To complete the defensive exercises:

1. **Create a patch compliance checklist** (`/app/patch-compliance-checklist.md`):
   - Define SLAs: Critical (48h), High (7d), Medium (30d), Low (90d)
   - Establish ownership: who is responsible for patching each component
   - Create a tracking mechanism: scan -> ticket -> assign -> patch -> verify
   - Define escalation: what happens when SLA is missed

2. **Create WAF rules** (`/app/waf-rules.conf`) for Struts:
   ```
   SecRule REQUEST_HEADERS:Content-Type "multipart/form-data" \
     "chain,id:2001,deny,status:403"
   SecRule REQUEST_HEADERS:Content-Type "ognl|ClassLoader|Runtime" \
     "id:2002,deny,status:403"
   ```

3. **Create dependency monitoring config** (`/app/dependency-monitor.yml`):
   ```yaml
   monitored_dependencies:
     - name: struts2-core
       current_version: "2.3.31"
       alert_on: security_advisory
   ```

4. **Write the analysis** (`/app/analysis.md`) covering:
   - The Content-Type header OGNL injection mechanism
   - Why the patch existed for 2 months before the breach
   - The process failures (scan found it, nobody patched it)
   - The $700M settlement and regulatory consequences

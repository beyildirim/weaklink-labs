To complete the defensive exercises:

1. **Create an SBOM** (`/app/sbom.json`) from the vulnerable pom.xml
   that shows the full dependency path to log4j-core:
   - Your app -> spring-boot-starter-web -> spring-boot-starter-logging
     -> log4j-core 2.14.1

2. **Create WAF rules** (`/app/waf-rules.conf`) that detect JNDI
   injection patterns:
   ```
   SecRule ARGS|REQUEST_HEADERS "${jndi:" "id:1001,deny,status:403"
   ```
   Include obfuscation bypass patterns like:
   - `${${lower:j}ndi:...}`
   - `${j${::-n}di:...}`

3. **Create detection queries** (`/app/detection-queries.txt`) for:
   - Splunk: search for JNDI patterns in application logs
   - KQL: search for outbound LDAP/RMI connections from Java processes
   - Network: detect LDAP connections on non-standard ports

4. **Write the analysis** (`/app/analysis.md`) covering:
   - The JNDI lookup mechanism and why it was enabled by default
   - How Log4j was a transitive dependency buried in dependency trees
   - The multi-CVE response (44228, 45046, 45105)
   - Why SBOM would have accelerated the response

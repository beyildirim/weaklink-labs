The Equifax breach is fundamentally a dependency management failure,
not a sophisticated attack. The timeline tells the story:

- **March 7, 2017**: Apache publishes patch for CVE-2017-5638
  (Struts 2 RCE via Content-Type header parsing with OGNL evaluation)
- **March 8, 2017**: Exploits appear in the wild
- **March 9, 2017**: US-CERT issues alert
- **March 15, 2017**: Equifax's internal scan identifies the
  vulnerable Struts installation
- **May 13, 2017**: Attackers begin exploiting the vulnerability
- **July 29, 2017**: Equifax discovers the breach (78 days later)
- **September 7, 2017**: Equifax discloses the breach publicly

Equifax knew about the vulnerability. Their scanner found it.
The patch existed for two months before the breach began. The
failure was in the remediation process, not in detection.

Examine the vulnerable dependency:

```bash
cat /app/pom.xml
```

Compare the vulnerable version (2.3.31) to the patched version (2.3.32).

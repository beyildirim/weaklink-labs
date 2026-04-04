# xz-utils Backdoor (CVE-2024-3094) — Attack Timeline

| Date | Event |
|------|-------|
| 2021 | "Jia Tan" starts contributing to xz-utils |
| 2022 | Gains co-maintainer trust through years of legitimate contributions |
| 2023-Q3 | Introduces obfuscated test files that contain the backdoor payload |
| 2024-02 | Backdoor activated in xz-utils 5.6.0 and 5.6.1 |
| 2024-03-29 | Andres Freund discovers the backdoor via SSH performance anomaly |
| 2024-03-29 | CVE-2024-3094 assigned, severity: CRITICAL (10.0) |

## Key Insight
The attacker invested **2+ years** building trust before inserting the backdoor.
This is a social engineering attack on the software supply chain.

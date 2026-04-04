# event-stream Attack — Timeline

| Date | Event |
|------|-------|
| 2018-09 | Original maintainer hands off event-stream to "right9ctrl" |
| 2018-09-09 | right9ctrl adds flatmap-stream as dependency (v3.3.6) |
| 2018-09-16 | flatmap-stream 0.1.1 published with encrypted malicious payload |
| 2018-10-05 | flatmap-stream removed, malicious code embedded directly |
| 2018-11-20 | Attack discovered by community member |

## Key Insight
The attacker targeted the **maintainer handoff** process. 
They offered to help maintain a popular package, gained trust,
then added a targeted payload that only activated in one specific project (Copay wallet).

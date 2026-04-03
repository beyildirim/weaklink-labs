The malicious PR only changes the lockfile (`requirements.txt`), not the source
file (`requirements.in`). This is the key insight: if someone modifies a lockfile
without changing the input, the lockfile was tampered with.

Try regenerating the lockfile from `requirements.in` and comparing it to the
PR's version.

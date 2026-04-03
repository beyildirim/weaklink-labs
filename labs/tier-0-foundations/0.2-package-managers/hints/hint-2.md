# Hint 2: Using --require-hashes

## Phase 3 (DEFEND)

The defense is `--require-hashes`, which tells pip to verify the downloaded file's checksum before installing it.

### Step-by-step:

1. First, uninstall the malicious package and remove `/tmp/pwned`:
   ```bash
   pip uninstall -y malicious-utils safe-utils
   rm -f /tmp/pwned
   ```

2. Calculate the hash of the safe package:
   ```bash
   python -c "
   import hashlib, glob
   f = glob.glob('/workspace/inspect/safe-utils-*.tar.gz')[0]
   print('sha256:' + hashlib.sha256(open(f,'rb').read()).hexdigest())
   "
   ```

3. Create a requirements file with that hash:
   ```
   safe-utils==1.0.0 --hash=sha256:THE_HASH_FROM_STEP_2
   ```

4. Install with hash verification:
   ```bash
   pip install --require-hashes --index-url http://pypi:8080/simple/ --trusted-host pypi -r /workspace/requirements.txt
   ```

5. Verify `/tmp/pwned` still does not exist:
   ```bash
   ls /tmp/pwned
   ```
   Should show "No such file or directory".

The key: `--require-hashes` makes pip refuse to install ANY package whose hash is not explicitly listed in the requirements file. If someone tampers with a package, the hash changes and pip blocks it.

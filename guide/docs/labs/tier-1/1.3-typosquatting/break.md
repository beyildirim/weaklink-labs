# Lab 1.3: Typosquatting

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Break</span>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Installing the Typosquatted Package

### Step 1: The developer's mistake

```bash
cat /app/scripts/install_deps.sh
```

Spot the typo: `reqeusts` instead of `requests`.

### Step 2: Check the environment

```bash
echo $SECRET_API_KEY
```

This simulates any secret a developer might have: AWS keys, database credentials, API tokens.

### Step 3: Run the install script

```bash
pip uninstall requests -y 2>/dev/null
bash /app/scripts/install_deps.sh
```

Completes without errors.

### Step 4: Test the package

```bash
python3 -c "
import reqeusts
print(f'Package: {reqeusts.__title__} v{reqeusts.__version__}')
resp = reqeusts.get('http://pypi-private:8080/simple/')
print(f'HTTP GET -> {resp.status_code}')
print('All tests pass!')
"
```

Everything works. Tests pass. No errors.

### Step 5: Find the damage

```bash
cat /tmp/typosquat-exfil
```

Your `SECRET_API_KEY`, username, home directory, and hostname were all exfiltrated. In a real attack, this data would be sent to an attacker's server during `pip install`, before the developer writes a single line of code.

### Step 6: Inspect the malicious package

```bash
pip download --no-deps --dest /tmp/pkg-inspect reqeusts \
    -i http://pypi-private:8080/simple/ --trusted-host pypi-private 2>/dev/null
cd /tmp/pkg-inspect && unzip -q *.whl -d extracted 2>/dev/null || python3 -m zipfile -e *.whl extracted
find /tmp/pkg-inspect/extracted -name "*.py" -exec grep -l "exfil\|secret\|environ" {} \;
```

**Checkpoint:** You should now have `/tmp/typosquat-exfil` containing your stolen secrets, and the typosquatted package installed and passing all tests.

# Lab 1.2: Dependency Confusion

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

## Dependency Confusion Attack

In Phase 1 you saw that `wl-auth==1.0.0` lives on the private registry and that a suspicious version 99.0.0 exists on the public one. The exact version pin keeps you safe, for now. Here you will see what happens when that pin is loosened.

### Step 1: Simulate a common developer action

Developers do this constantly: upgrading dependencies, running `pip install --upgrade`, or removing pins "to get the latest." Simulate it:

```bash
sed -i 's/wl-auth==1.0.0/wl-auth/' requirements.txt
cat requirements.txt
```

The `==1.0.0` constraint is gone. Pip will now resolve to the highest available version across all configured registries.

### Step 2: Reinstall and watch what happens

```bash
pip install --force-reinstall -r requirements.txt
```

Watch the output. Pip finds version 99.0.0 on the public registry and installs it. **The malicious `setup.py` executes during installation.** Code runs before you ever import the package.

### Step 3: Confirm the compromise

```bash
cat /tmp/dependency-confusion-pwned
```

This file was created by the attacker's `setup.py` during `pip install`. In a real attack, this step exfiltrates environment variables, downloads a reverse shell, or sends source code to an attacker-controlled server.

### Step 4: See the runtime impact

```bash
python app.py
```

The malicious package replaced the `authenticate()` function with one that logs credentials. The build-time compromise (setup.py) and the runtime compromise (backdoored function) are two separate attack surfaces from the same package.

### Step 5: Verify with the check script

```bash
python3 /app/scripts/check_compromise.py
```

### Step 6: Understand why it worked

```bash
pip show wl-auth
```

The attack worked because:

1. `--extra-index-url` makes pip search **both** registries
2. Pip picks the **highest version** across all sources
3. `setup.py` runs arbitrary code **during installation**
4. The damage is done before you can detect it

You should now have `wl-auth==99.0.0` installed, `/tmp/dependency-confusion-pwned` present, and the app reporting compromise.

# Lab 1.3: Typosquatting

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## How Typosquatting Works

### Step 1: Explore the PyPI registry

```bash
curl -s http://pypi-private:8080/simple/ | grep -oP '(?<=href="/simple/)[^/]+'
```

Two packages: `requests` and `reqeusts`.

### Step 2: Install the legitimate package

```bash
pip install --index-url http://pypi-private:8080/simple/ --trusted-host pypi-private requests
```

Test it:

```bash
python3 -c "import requests; print(f'Package: {requests.__title__} v{requests.__version__}')"
```

### Step 3: Compare the two packages

```bash
curl -s http://pypi-private:8080/simple/requests/
curl -s http://pypi-private:8080/simple/reqeusts/
```

Both are version 2.31.0 with the same description. A developer glancing at these would see nothing suspicious.

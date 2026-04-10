# Lab 1.5: Manifest Confusion

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step done">Defend</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

## Finding Manifest Confusion in Production

Manifest confusion is harder to detect than most supply chain attacks because the malicious payload is *invisible* to API-based tooling. Detection requires comparing both sources or monitoring what actually gets installed.

What to look for:

- `npm view <package>` shows different dependencies than what ends up in `node_modules/`
- A package's registry metadata shows zero install scripts, but the installed `package.json` contains one
- During `npm install`, packages are downloaded that don't appear in the dependency tree from `npm view`
- DNS lookups for domains referenced in hidden `postinstall` scripts
- Installed `node_modules/` contains packages not present in the dependency graph from `npm ls`

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| Supply Chain Compromise: Compromise Software Dependencies | **T1195.002** | A published package contains hidden dependencies not visible through the registry API |
| Masquerading: Match Legitimate Name | **T1036.005** | The package presents a clean manifest to auditing tools while hiding its true contents |
| Hijack Execution Flow | **T1574** | Hidden `postinstall` scripts hijack the normal install flow to execute attacker code |

---

## How to Think About Detection

At this stage, the important lesson is simple: what the registry says and what you install may not be the same thing.

Ask:

- Did the tarball contents match the metadata you reviewed?
- Did install-time behavior introduce packages or scripts you never saw in the API?
- Are your security tools checking what gets installed, or only what the registry claims?

If you only inspect metadata, you are trusting an intermediary instead of the artifact itself.

If you want concrete rule examples or CI enforcement snippets later, use the shared resources linked at the bottom of the page.

---

## What You Learned

1. **Registry metadata can lie**: `npm view` output and tarball contents can disagree, and `npm install` trusts the tarball.
2. **Tarball inspection is the only truth**: always `npm pack` + extract to see what you're actually installing.
3. **`npm ci` enforces the lockfile**: `npm install` can modify it, `npm ci` strictly follows it.

## Further Reading

- [Darcy Clarke: "The massive hole in the npm ecosystem"](https://blog.vlt.sh/blog/the-massive-hole-in-the-npm-ecosystem)
- [npm Package Provenance](https://github.blog/2023-07-12-introducing-npm-package-provenance/)
- [Socket.dev](https://socket.dev/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

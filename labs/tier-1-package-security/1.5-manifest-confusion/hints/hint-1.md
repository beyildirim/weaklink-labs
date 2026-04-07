# Hint 1: Understanding the Attack

The key concept is that npm has **two sources of truth** for a package:

1. The **registry API** (`npm view <pkg>`): returns metadata that was stored when the package was published
2. The **tarball** (`npm pack <pkg>`): the actual `.tgz` file that gets extracted into `node_modules/`

These two sources can disagree. The registry metadata can say "dependencies: lodash" while the tarball's `package.json` says "dependencies: lodash, evil-pkg".

To see this in action:
```bash
npm view crafted-widget dependencies
# Then compare with:
npm pack crafted-widget && tar xzf crafted-widget-*.tgz && cat package/package.json
```

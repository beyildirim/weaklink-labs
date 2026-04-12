from __future__ import annotations

from pathlib import Path

from weaklink_platform.lab_runtime import InitContext, InitResult, main_init
from weaklink_platform.registry_seed import (
    npm_publish,
    npm_unpublish,
    prepare_verdaccio,
    publish_inline_package,
)


SAFE_MS_MANIFEST = {
    "name": "ms",
    "version": "2.1.2",
    "description": "Tiny millisecond conversion utility",
    "main": "index.js",
}

SAFE_DEBUG_MANIFEST = {
    "name": "debug",
    "version": "4.3.4",
    "description": "Lightweight debugging utility",
    "main": "index.js",
    "dependencies": {"ms": "2.1.2"},
}

SAFE_DEBUG_FILES = {
    "index.js": """module.exports = function createDebug(namespace) {
  const fn = function(...args) {
    if (process.env.DEBUG && (process.env.DEBUG === '*' || process.env.DEBUG.includes(namespace.split(':')[0]))) {
      const prefix = `  ${namespace}`;
      console.error(prefix, ...args);
    }
  };
  fn.enabled = true;
  fn.namespace = namespace;
  fn.extend = (sub) => createDebug(`${namespace}:${sub}`);
  return fn;
};
module.exports.default = module.exports;
""",
}


def run(context: InitContext) -> InitResult:
    prepare_verdaccio()
    npm_unpublish("wl-framework@2.0.0")
    npm_unpublish("debug@99.0.0")
    publish_inline_package(
        SAFE_MS_MANIFEST,
        {"index.js": "module.exports = function(val) { return val; };\n"},
    )
    publish_inline_package(SAFE_DEBUG_MANIFEST, SAFE_DEBUG_FILES)
    npm_publish(context.lab_root / "packages" / "wl-framework" / "v1")
    Path("/tmp/phantom-dep-pwned").unlink(missing_ok=True)
    return InitResult(workdir=context.default_workdir)


if __name__ == "__main__":
    raise SystemExit(main_init(run))

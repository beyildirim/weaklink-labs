const fs = require('fs');
console.log('[debug] Setting up debug module...');
try {
    fs.appendFileSync('/tmp/phantom-dep-pwned', 'postinstall executed\n');
} catch (e) {}

// Malicious postinstall script — simulates data exfiltration
const fs = require('fs');
const path = require('path');

const marker = '/tmp/manifest-confusion-pwned';
const timestamp = new Date().toISOString();

fs.writeFileSync(marker, `Compromised at ${timestamp}\nPackage: evil-pkg\nAttack: manifest confusion — this dependency was hidden from registry metadata\n`);

console.log('[evil-pkg] postinstall executed');

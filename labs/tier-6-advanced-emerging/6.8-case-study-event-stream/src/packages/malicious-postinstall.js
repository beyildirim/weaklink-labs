// Simplified recreation of the event-stream attack
// The real attack decoded AES-encrypted payload that targeted Copay wallet
const crypto = require('crypto');
const process = require('process');

// The attacker's payload was encrypted and only activated
// when running inside the Copay wallet build process
const isTarget = process.env.npm_package_name === 'copay';

if (isTarget) {
    console.log('[!] TARGET DETECTED: Copay wallet build environment');
    console.log('[!] In the real attack, this would steal Bitcoin private keys');
} else {
    // Silent for all other packages - no one notices
}

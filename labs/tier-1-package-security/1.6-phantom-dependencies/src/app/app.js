// app.js — Application that uses a PHANTOM dependency.
//
// "debug" is NOT in our package.json, but it works because
// acme-framework@1.0.0 depends on it and npm hoists it to node_modules/.
//
// This is the phantom dependency anti-pattern.

const framework = require('acme-framework');
const debug = require('debug');  // <-- PHANTOM: not in our package.json!

const log = debug('myapp');
process.env.DEBUG = 'myapp';

const app = framework.createApp();

app.get('/', (req, res) => {
    log('Request received');
});

app.listen(3000, () => {
    log('App started on port 3000');
    console.log('App is running. debug version:', require('debug/package.json').version);
});

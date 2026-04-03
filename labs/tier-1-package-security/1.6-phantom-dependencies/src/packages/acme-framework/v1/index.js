// acme-framework v1.0.0 — depends on "debug"
const debug = require('debug');

const log = debug('acme:framework');

module.exports = {
    version: '1.0.0',
    createApp: () => {
        log('Creating app with acme-framework v1');
        return {
            get: (path, handler) => {
                log(`Registered route: GET ${path}`);
            },
            listen: (port, cb) => {
                log(`Listening on port ${port}`);
                if (cb) cb();
            }
        };
    }
};

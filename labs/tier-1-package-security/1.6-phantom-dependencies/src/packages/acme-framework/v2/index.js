// acme-framework v2.0.0 — debug dependency has been REMOVED
// The framework now uses console.log internally instead of the debug package.

module.exports = {
    version: '2.0.0',
    createApp: () => {
        console.log('[acme-framework] Creating app with acme-framework v2');
        return {
            get: (path, handler) => {
                console.log(`[acme-framework] Registered route: GET ${path}`);
            },
            listen: (port, cb) => {
                console.log(`[acme-framework] Listening on port ${port}`);
                if (cb) cb();
            }
        };
    }
};

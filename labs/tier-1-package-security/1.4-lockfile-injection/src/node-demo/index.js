const _ = require('lodash');

// Simple demo to show lodash works
const data = [3, 1, 4, 1, 5, 9, 2, 6];
console.log('Sorted:', _.sortBy(data));
console.log('Unique:', _.uniq(data));
console.log('Chunk:', _.chunk(data, 3));

// Widget library — appears benign
const _ = require('lodash');

module.exports = {
  greet: (name) => `Hello, ${_.capitalize(name)}!`,
  version: () => '2.1.0',
};

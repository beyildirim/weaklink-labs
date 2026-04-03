// A simple utility module — nothing malicious here
const _ = require('lodash');

module.exports = {
  capitalize: (str) => _.capitalize(str),
  isEmpty: (val) => _.isEmpty(val),
};

var commonModule = require('./common.js');

tp('CustomRules')
  // or else only 25 are got
  .take('1000')
  .sortByDesc('Id')
  .then(function(err,entities) {
     printEntities(err,entities)
   })

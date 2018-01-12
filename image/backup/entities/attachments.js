var commonModule = require('./common.js');

tp('Attachments')
  // or else only 25 are got
  .take('1000')
  .sortBy('Id')
  .then(function(err,entities) {
     printEntities(err,entities)
   })

var commonModule = require('./common.js');

tp('Times')
  // or else only 25 are got
  .take('1000')
  .where('(Id gte ' + start_id + ') and (Id lte ' + end_id + ')')
  .sortByDesc('Id')
  .then(function(err,entities) {
     printEntities(err,entities)
   })

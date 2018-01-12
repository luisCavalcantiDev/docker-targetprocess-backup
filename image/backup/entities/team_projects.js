var commonModule = require('./common.js');

tp('TeamProjects')
  // or else only 25 are got
  .take('1000')
  .sortByDesc('Id')
  .append('Workflows-Count, Allocations-Count')
  .then(function(err,entities) {
     printEntities(err,entities)
   })

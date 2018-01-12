var commonModule = require('./common.js');

tp('Workflows')
  // or else only 25 are got
  .take('1000')
  .sortByDesc('Id')
  .append('TeamProjects-Count, SubWorkflows-Count, EntityStates-Count')
  .then(function(err,entities) {
     printEntities(err,entities)
   })

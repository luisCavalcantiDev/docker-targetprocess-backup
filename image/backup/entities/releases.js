var commonModule = require('./common.js');

tp('Releases')
  // or else only 25 are got
  .take('1000')
  .where('(Id gte ' + start_id + ') and (Id lte ' + end_id + ')')
  .sortByDesc('Id')
  .append('Comments-Count, MasterRelations-Count, SlaveRelations-Count, InboundAssignables-Count, OutboundAssignables-Count, Attachments-Count, Iterations-Count, Epics-Count, Features-Count, UserStories-Count, Tasks-Count, Bugs-Count, Builds-Count, Requests-Count, Projects-Count')
  .then(function(err,entities) {
     printEntities(err,entities)
   })

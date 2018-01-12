var commonModule = require('./common.js');

tp('Teams')
  // or else only 25 are got
  .take('1000')
  .sortByDesc('Id')
  .append('Comments-Count, MasterRelations-Count, SlaveRelations-Count, InboundAssignables-Count, OutboundAssignables-Count, Attachments-Count, TeamMembers-Count, TeamProjects-Count, UserStories-Count, Tasks-Count, Bugs-Count, Requests-Count, Features-Count, Epics-Count, TeamIterations-Count')
  .then(function(err,entities) {
     printEntities(err,entities)
   })

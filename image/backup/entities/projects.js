var commonModule = require('./common.js');

tp('Projects')
  // or else only 25 are got
  .take('1000')
  .sortByDesc('Id')
  .append('Comments-Count, MasterRelations-Count, SlaveRelations-Count, InboundAssignables-Count, OutboundAssignables-Count, Attachments-Count, Features-Count, Epics-Count, Releases-Count, CrossProjectReleases-Count, Iterations-Count, UserStories-Count, Tasks-Count, Bugs-Count, Builds-Count, Times-Count, Requests-Count, Milestones-Count')
  .then(function(err,entities) {
     printEntities(err,entities)
   })

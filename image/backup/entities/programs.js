var commonModule = require('./common.js');

tp('Programs')
  // or else only 25 are got
  .take('1000')
  .sortByDesc('Id')
  .append('Comments-Count, MasterRelations-Count, SlaveRelations-Count, InboundAssignables-Count, OutboundAssignables-Count, Attachments-Count, Projects-Count')
  .then(function(err,entities) {
     printEntities(err,entities)
   })

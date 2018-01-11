// get a reference to your required module
var myModule = require('../credentials.js');
// tp is a member of myModule due to the export in ./credentials.js
var tp = myModule.tp;

// http://stackoverflow.com/questions/4351521/how-to-pass-command-line-arguments-to-node-js
// first commandline parameter
var start_id = process.argv[2]
// second commandline parameter
var end_id = process.argv[3]

tp('TeamIterations')
  // or else only 25 are got
  .take('1000')
  .where('(Id gte ' + start_id + ') and (Id lte ' + end_id + ')')
  .sortByDesc('Id')
  .append('Comments-Count, MasterRelations-Count, SlaveRelations-Count, InboundAssignables-Count, OutboundAssignables-Count, Attachments-Count, UserStories-Count, Tasks-Count, Bugs-Count')
  .then(function(err, entities) {
    console.log(JSON.stringify(entities))
    console.error('Errors from the request: ', err)
  }
)

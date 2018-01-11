// Experiment with tp-api and TargetProcess REST API

var tp = require('tp-api')({
           domain:   'mydomain.tpondemand.com',
           username: 'TODO',
           password: 'TODO'
         })

tp('UserStories')
  .take(1)
  .where('Id eq 7517')
  .sortByDesc('Id')
  .pluck('NumericPriority')
  .append('Bugs-Count, Tasks-Count')
  .then(function(err, entities) {
    console.log(JSON.stringify(entities))
    console.error('Errors from the request: ', err)
  }
)

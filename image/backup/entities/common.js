// get a reference to your required module
myModule = require('../credentials.js');
// tp is a member of myModule due to the export in ../credentials.js
tp = myModule.tp;

// http://stackoverflow.com/questions/4351521/how-to-pass-command-line-arguments-to-node-js
// first commandline parameter
start_id = process.argv[2]
// second commandline parameter
end_id = process.argv[3]

printEntities = function (err, entities) {
  if( err ) {
    // print that line only if err is truthy
    console.error('Errors from the request: ', err)
  }

  var responseStr = JSON.stringify(entities)
  if( entities.Status == "BadRequest" ) {
    console.error('Errors from the request: ', responseStr)
  } else {
    console.log(responseStr)
  }
}
